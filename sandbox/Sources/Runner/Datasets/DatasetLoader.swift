import Foundation
import TabularData
import Quiver

/// Single chokepoint that converts a CSV file into a concrete dataset value.
///
/// Tabular CSVs route through `loadTabular(name:csvURL:description:)`, which
/// parses with TabularData and:
///
/// - Copies numeric columns straight into `[Double]` (Int columns cast).
/// - Encodes string columns alphabetically (sorted unique values → 0…N) and
///   records the ordered class names in `categoricalMappings` so callers can
///   decode predictions back to label strings.
/// - Converts date columns to Unix timestamps (`timeIntervalSince1970`).
/// - Preserves missing values as `Double.nan` — never silently mean-imputed.
///
/// Embedding CSVs (currently just GloVe-50d) route through
/// `loadEmbeddings(name:csvURL:description:)`, which keeps `word` and
/// `nearest` as strings and reads the dimension columns as raw `Double`.
///
/// Both methods return `nil` if the CSV cannot be parsed at all. Tabular
/// columns whose element type is none of (numeric, String, Date) are skipped
/// with a warning to stderr.
internal enum DatasetLoader {

    static func loadTabular(name: String, csvURL: URL, description: String) -> TabularDataset? {
        guard let dataFrame = try? DataFrame(contentsOfCSVFile: csvURL) else {
            FileHandle.standardError.write(Data(
                "DatasetLoader: could not parse \(csvURL.lastPathComponent)\n".utf8
            ))
            return nil
        }

        var encodedColumns: [(String, [Double])] = []
        var categoricalMappings: [String: [String]] = [:]

        for column in dataFrame.columns {
            let columnName = column.name
            let elementType = column.wrappedElementType

            if elementType == Double.self {
                let typed = column.assumingType(Double.self)
                let values = typed.map { $0 ?? Double.nan }
                encodedColumns.append((columnName, values))

            } else if elementType == Int.self {
                let typed = column.assumingType(Int.self)
                let values = typed.map { intOpt -> Double in
                    guard let i = intOpt else { return Double.nan }
                    return Double(i)
                }
                encodedColumns.append((columnName, values))

            } else if elementType == Float.self {
                let typed = column.assumingType(Float.self)
                let values = typed.map { floatOpt -> Double in
                    guard let f = floatOpt else { return Double.nan }
                    return Double(f)
                }
                encodedColumns.append((columnName, values))

            } else if elementType == Bool.self {
                let typed = column.assumingType(Bool.self)
                let values = typed.map { boolOpt -> Double in
                    guard let b = boolOpt else { return Double.nan }
                    return b ? 1.0 : 0.0
                }
                encodedColumns.append((columnName, values))

            } else if elementType == String.self {
                // Collect unique non-nil strings, sort alphabetically,
                // map to 0…N indices, with NaN for missing entries.
                let typed = column.assumingType(String.self)
                var uniques = Set<String>()
                for cell in typed {
                    if let s = cell { uniques.insert(s) }
                }
                let ordered = uniques.sorted()
                var index: [String: Int] = [:]
                for (i, s) in ordered.enumerated() { index[s] = i }
                let values = typed.map { cell -> Double in
                    guard let s = cell, let i = index[s] else { return Double.nan }
                    return Double(i)
                }
                encodedColumns.append((columnName, values))
                categoricalMappings[columnName] = ordered

            } else if elementType == Date.self {
                let typed = column.assumingType(Date.self)
                let values = typed.map { dateOpt -> Double in
                    guard let d = dateOpt else { return Double.nan }
                    return d.timeIntervalSince1970
                }
                encodedColumns.append((columnName, values))

            } else {
                FileHandle.standardError.write(Data(
                    "DatasetLoader: skipping column '\(columnName)' in \(csvURL.lastPathComponent) — unsupported element type \(elementType)\n".utf8
                ))
                continue
            }
        }

        guard !encodedColumns.isEmpty else {
            FileHandle.standardError.write(Data(
                "DatasetLoader: no usable columns parsed from \(csvURL.lastPathComponent)\n".utf8
            ))
            return nil
        }

        let panel = Panel(encodedColumns)
        return TabularDataset(
            name: name,
            description: description,
            categoricalMappings: categoricalMappings,
            panel: panel
        )
    }

    static func loadEmbeddings(name: String, csvURL: URL, description: String) -> EmbeddingsDataset? {
        guard let dataFrame = try? DataFrame(contentsOfCSVFile: csvURL) else {
            FileHandle.standardError.write(Data(
                "DatasetLoader: could not parse \(csvURL.lastPathComponent)\n".utf8
            ))
            return nil
        }

        // Required textual / scalar columns. Missing any of them means the
        // CSV doesn't match the embeddings schema we expect.
        let columnsByName = Dictionary(uniqueKeysWithValues: dataFrame.columns.map { ($0.name, $0) })
        guard
            let wordColumn = columnsByName["word"],
            wordColumn.wrappedElementType == String.self,
            let rankColumn = columnsByName["rank"],
            rankColumn.wrappedElementType == Int.self,
            let magnitudeColumn = columnsByName["magnitude"],
            magnitudeColumn.wrappedElementType == Double.self,
            let nearestColumn = columnsByName["nearest"],
            nearestColumn.wrappedElementType == String.self
        else {
            FileHandle.standardError.write(Data(
                "DatasetLoader: \(csvURL.lastPathComponent) is missing one of the required embedding columns (word, rank, magnitude, nearest)\n".utf8
            ))
            return nil
        }

        // Collect dimension column names in numerical order — `dim_01` first,
        // not whatever order TabularData iterates them in.
        let dimensionNames = dataFrame.columns
            .map { $0.name }
            .filter { $0.hasPrefix("dim_") }
            .sorted()

        guard !dimensionNames.isEmpty else {
            FileHandle.standardError.write(Data(
                "DatasetLoader: \(csvURL.lastPathComponent) has no dim_* columns\n".utf8
            ))
            return nil
        }

        let words = wordColumn.assumingType(String.self)
        let ranks = rankColumn.assumingType(Int.self)
        let magnitudes = magnitudeColumn.assumingType(Double.self)
        let nearests = nearestColumn.assumingType(String.self)

        // Pre-collect each dim column as a Double slice so the per-row build
        // is a fast O(rows × dims) loop without re-indexing TabularData.
        var dimSlices: [[Double?]] = []
        dimSlices.reserveCapacity(dimensionNames.count)
        for dim in dimensionNames {
            guard let column = columnsByName[dim],
                  column.wrappedElementType == Double.self else {
                FileHandle.standardError.write(Data(
                    "DatasetLoader: \(csvURL.lastPathComponent) column '\(dim)' is not Double\n".utf8
                ))
                return nil
            }
            let typed = column.assumingType(Double.self)
            dimSlices.append(typed.map { $0 })
        }

        var vectors: [String: [Double]] = [:]
        var rankByWord: [String: Int] = [:]
        var magnitudeByWord: [String: Double] = [:]
        var nearestByWord: [String: String] = [:]
        let rowCount = words.count
        vectors.reserveCapacity(rowCount)

        for row in 0..<rowCount {
            guard let word = words[row] else { continue }

            var vector: [Double] = []
            vector.reserveCapacity(dimensionNames.count)
            for d in 0..<dimensionNames.count {
                vector.append(dimSlices[d][row] ?? Double.nan)
            }

            vectors[word] = vector
            if let r = ranks[row] { rankByWord[word] = r }
            if let m = magnitudes[row] { magnitudeByWord[word] = m }
            if let n = nearests[row] { nearestByWord[word] = n }
        }

        guard !vectors.isEmpty else {
            FileHandle.standardError.write(Data(
                "DatasetLoader: no usable rows parsed from \(csvURL.lastPathComponent)\n".utf8
            ))
            return nil
        }

        // Build the vocabulary by sorting words by their rank ascending so
        // `vocabulary[0]` is the most-frequent word. Words without a rank
        // (shouldn't happen with the bundled CSV) sink to the end stably.
        let vocabulary = vectors.keys.sorted { lhs, rhs in
            let lr = rankByWord[lhs] ?? Int.max
            let rr = rankByWord[rhs] ?? Int.max
            if lr != rr { return lr < rr }
            return lhs < rhs
        }

        return EmbeddingsDataset(
            name: name,
            description: description,
            dimensions: dimensionNames.count,
            vocabulary: vocabulary,
            vectors: vectors,
            ranks: rankByWord,
            magnitudes: magnitudeByWord,
            nearestWords: nearestByWord
        )
    }
}
