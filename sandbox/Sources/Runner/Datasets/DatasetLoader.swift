import Foundation
import TabularData
import Quiver

/// Single chokepoint that converts a CSV file into a `Dataset`.
///
/// Both bundled accessors (`Dataset.iris`, etc.) and the user-facing
/// `Dataset.load(path:)` route through `DatasetLoader.load(name:csvURL:description:)`.
/// TabularData parses the CSV and infers per-column types; this loader then:
///
/// - Copies numeric columns straight into `[Double]` (Int columns cast).
/// - Encodes string columns alphabetically (sorted unique values → 0…N) and
///   records the ordered class names in `categoricalMappings` so callers can
///   decode predictions back to label strings.
/// - Converts date columns to Unix timestamps (`timeIntervalSince1970`).
/// - Preserves missing values as `Double.nan` — never silently mean-imputed.
///
/// Returns `nil` if the CSV cannot be parsed at all. Columns whose element type
/// is none of (numeric, String, Date) are skipped with a warning to stderr.
internal enum DatasetLoader {

    static func load(name: String, csvURL: URL, description: String) -> Dataset? {
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
        return Dataset(
            name: name,
            description: description,
            categoricalMappings: categoricalMappings,
            panel: panel
        )
    }
}
