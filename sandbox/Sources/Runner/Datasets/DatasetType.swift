import Quiver

/// Public namespace for bundled datasets.
///
/// `Dataset` is an empty enum used purely as a namespace — there are no
/// `Dataset` instances. Each bundled accessor returns a concrete dataset
/// type: tabular collections (iris, titanic, etc.) come back as
/// `TabularDataset`, while the GloVe word-embedding slice comes back as
/// `EmbeddingsDataset`.
public enum Dataset {}

/// A bundled tabular dataset wrapping a Quiver `Panel` of numeric columns.
///
/// Strings in the source CSV are alphabetically encoded to `Double` indices and
/// the original ordered class names are stashed in `categoricalMappings` so
/// students can decode predictions back to label strings. Missing values are
/// preserved as `Double.nan` rather than mean-imputed.
public struct TabularDataset: CustomStringConvertible, Sendable {
    /// Short identifier — `"iris"`, `"titanic"`, etc., or for `Dataset.load(path:)`,
    /// the input filename without its extension.
    public let name: String

    /// Human-readable summary of the dataset's origin, row count, columns, and
    /// any cleaning that was applied. For example, the bundled `iris` dataset's
    /// description records that it holds 150 rows across three species, four
    /// numeric features, and was originally published by R. A. Fisher in 1936.
    ///
    /// This is the value `print(dataset)` shows (`EmbeddingsDataset` and this
    /// type conform to `CustomStringConvertible` via this property), so a print
    /// surfaces the dataset's metadata rather than dumping its backing store.
    /// Use `shape`, `count`, and `head()` to inspect structure and rows.
    public let description: String

    /// Maps an original column name to the ordered class names produced when
    /// that column's strings were alphabetically encoded into `Double` indices.
    ///
    /// Use it to decode a predicted or stored encoded value back to a label:
    ///
    ///     let speciesName = dataset.categoricalMappings["species"]?[Int(label)]
    ///
    /// Numeric columns do not appear in this dictionary. Missing string cells
    /// are stored as `Double.nan` in the underlying panel rather than being
    /// assigned a mapping index.
    public let categoricalMappings: [String: [String]]

    private let panel: Panel

    internal init(
        name: String,
        description: String,
        categoricalMappings: [String: [String]],
        panel: Panel
    ) {
        self.name = name
        self.description = description
        self.categoricalMappings = categoricalMappings
        self.panel = panel
    }

    /// Returns the underlying Quiver `Panel` so the rest of the Quiver API
    /// (`head()`, `summary()`, `trainTestSplit()`, `toMatrix()`, etc.) is
    /// available on the dataset's columns.
    ///
    /// Example:
    ///
    ///     let panel = Dataset.iris!.toPanel()
    ///     panel.head()
    ///
    /// Categorical columns appear in the returned panel as `[Double]` indices,
    /// not strings — decode them through `categoricalMappings` when a label
    /// name is needed:
    ///
    ///     let label = panel["species"]![0]
    ///     let name = dataset.categoricalMappings["species"]?[Int(label)]
    public func toPanel() -> Panel {
        panel
    }

    /// Number of rows in the dataset. Matches `Array.count` muscle memory —
    /// `iris.count` reads as "how many samples do I have?".
    public var count: Int {
        panel.shape.rows
    }

    /// Row and column counts as a tuple. Confirms a load matches the
    /// student's mental model before any modeling work.
    public var shape: (rows: Int, columns: Int) {
        panel.shape
    }

    /// Ordered column names. Use to confirm the expected features arrived
    /// after loading.
    public var columnNames: [String] {
        panel.columnNames
    }

    /// Returns the values of a single column by name, or `nil` if the column
    /// is not in the dataset. Categorical columns return `Double` indices —
    /// decode them through `categoricalMappings`.
    public subscript(column: String) -> [Double]? {
        guard panel.columnNames.contains(column) else { return nil }
        return panel[column]
    }

    /// Returns the first rows of the dataset as a formatted table — the
    /// first thing to type after loading.
    public func head(n: Int = 10) -> String {
        panel.head(n: n)
    }
}

/// A bundled word-embedding dataset — words mapped to fixed-length vectors.
///
/// Each entry pairs a word with its rank, magnitude, nearest-neighbour word,
/// and the embedding vector itself. Words are first-class strings throughout,
/// never integer-encoded. Use the subscript to pull a vector
/// (`glove["king"]`), `nearest(to:k:)` for similarity search, and
/// `analogy(_:_:_:k:)` for the classic king − man + woman ≈ queen pattern.
public struct EmbeddingsDataset: CustomStringConvertible, Sendable {
    /// Short identifier — for example, `"glove50d"`.
    public let name: String

    /// Human-readable summary of the dataset's origin, vocabulary size, and
    /// vector dimensionality.
    ///
    /// This is the value `print(dataset)` shows (the type conforms to
    /// `CustomStringConvertible` via this property), so a print surfaces the
    /// dataset's metadata rather than dumping its backing vectors. Use `shape`,
    /// `count`, and `head()` to inspect structure and rows.
    public let description: String

    /// Number of components in each embedding vector — `50` for the bundled
    /// GloVe-50d slice.
    public let dimensions: Int

    /// Every word in the dataset, sorted by rank ascending. `vocabulary[0]`
    /// is the most-frequent word (`"the"` in the bundled GloVe slice).
    public let vocabulary: [String]

    private let vectors: [String: [Double]]
    private let ranks: [String: Int]
    private let magnitudes: [String: Double]

    /// Number of words in the dataset. Mirrors `TabularDataset.count` —
    /// `glove.count` reads as "how many words do I have?".
    public var count: Int {
        vocabulary.count
    }

    /// Vocabulary size and vector width as a tuple, parallel to
    /// `TabularDataset.shape`. Labelled `(words, dimensions)` because an
    /// embedding set is a word-to-vector lookup, not a row/column table.
    public var shape: (words: Int, dimensions: Int) {
        (words: vocabulary.count, dimensions: dimensions)
    }

    internal init(
        name: String,
        description: String,
        dimensions: Int,
        vocabulary: [String],
        vectors: [String: [Double]],
        ranks: [String: Int],
        magnitudes: [String: Double]
    ) {
        self.name = name
        self.description = description
        self.dimensions = dimensions
        self.vocabulary = vocabulary
        self.vectors = vectors
        self.ranks = ranks
        self.magnitudes = magnitudes
    }

    /// Returns the embedding vector for a word, or `nil` if the word is not
    /// in the vocabulary.
    public subscript(word: String) -> [Double]? {
        vectors[word]
    }

    /// Returns the full word-to-vector dictionary. Useful when an algorithm
    /// expects a `[String: [Double]]` directly.
    public func asDictionary() -> [String: [Double]] {
        vectors
    }

    /// Returns the `k` nearest words to a query word by cosine similarity,
    /// excluding the query word itself. Returns `[]` when the query word is
    /// not in the vocabulary.
    ///
    /// Example:
    ///
    ///     let glove = Dataset.glove50d!
    ///     for hit in glove.nearest(to: "paris", k: 5) {
    ///         print(hit.rank, hit.word, hit.score)
    ///     }
    ///
    /// - Parameters:
    ///   - word: The query word.
    ///   - k: Maximum number of results. Defaults to 5.
    /// - Returns: Tuples of `(rank, word, score)` sorted by score descending.
    ///   `rank` is 1-based — the closest word has rank 1.
    public func nearest(to word: String, k: Int = 5) -> [(rank: Int, word: String, score: Double)] {
        guard let query = vectors[word] else { return [] }
        return topMatches(target: query, exclude: [word], k: k)
    }

    /// Returns the `k` words that best complete the analogy "a is to b as c
    /// is to ?". The classic example is `analogy("king", "man", "woman")`,
    /// which targets `king − man + woman` and typically returns `"queen"`.
    /// Returns `[]` if any of `a`, `b`, or `c` is not in the vocabulary.
    ///
    /// - Parameters:
    ///   - a: First term in the analogy (the source noun, e.g. `"king"`).
    ///   - b: Second term (the source attribute, e.g. `"man"`).
    ///   - c: Third term (the target attribute, e.g. `"woman"`).
    ///   - k: Maximum number of results. Defaults to 1.
    /// - Returns: Tuples of `(rank, word, score)` sorted by score descending.
    ///   `rank` is 1-based.
    public func analogy(_ a: String, _ b: String, _ c: String, k: Int = 1) -> [(rank: Int, word: String, score: Double)] {
        guard
            let va = vectors[a],
            let vb = vectors[b],
            let vc = vectors[c]
        else {
            return []
        }
        let target = va.subtract(vb).add(vc)
        return topMatches(target: target, exclude: [a, b, c], k: k)
    }

    /// Returns the frequency rank of a word, or `nil` if the word is not in
    /// the vocabulary. Rank `1` is the most-frequent word.
    public func rank(of word: String) -> Int? {
        ranks[word]
    }

    /// Returns the precomputed magnitude (Euclidean norm) of a word's
    /// embedding vector, or `nil` if the word is not in the vocabulary.
    public func magnitude(of word: String) -> Double? {
        magnitudes[word]
    }

    /// Returns the nearest neighbour for a word — the closest other word by
    /// cosine similarity — computed on demand from the loaded vectors. Returns
    /// `nil` if the word is not in the vocabulary. This is a thin convenience
    /// over `nearest(to:k:)` with `k == 1`; it does a single O(n) scan per
    /// call rather than reading a precomputed column.
    public func nearestWord(of word: String) -> String? {
        nearest(to: word, k: 1).first?.word
    }

    /// Returns the first rows of the dataset as a formatted table. The
    /// leftmost column shows the word itself; remaining columns show rank,
    /// magnitude, and the 50 embedding dimensions rounded to two decimal
    /// places. Rows are ordered by rank ascending. Nearest-neighbour lookups
    /// are not shown here — a preview stays a cheap dictionary read; use
    /// `nearest(to:k:)` or `nearestWord(of:)` for similarity queries.
    public func head(n: Int = 10) -> String {
        let displayRows = Swift.min(n, vocabulary.count)
        guard displayRows > 0 else { return "(empty EmbeddingsDataset)" }

        // Format an embedding component: two decimal places, no thousands separators.
        func formatComponent(_ value: Double) -> String {
            if value.isNaN { return "nan" }
            if value.isInfinite { return value > 0 ? "inf" : "-inf" }
            return String(format: "%.2f", value)
        }

        // Format the magnitude: four decimals, matching the precomputed precision.
        func formatMagnitude(_ value: Double) -> String {
            if value.isNaN { return "nan" }
            return String(format: "%.4f", value)
        }

        var headers: [String] = ["word", "rank", "magnitude"]
        for d in 1...dimensions {
            headers.append(String(format: "dim_%02d", d))
        }

        var rows: [[String]] = []
        for r in 0..<displayRows {
            let word = vocabulary[r]
            let rank = ranks[word].map { String($0) } ?? ""
            let mag = magnitudes[word].map(formatMagnitude) ?? ""
            let vec = vectors[word] ?? []
            var row: [String] = [word, rank, mag]
            for d in 0..<dimensions {
                row.append(d < vec.count ? formatComponent(vec[d]) : "")
            }
            rows.append(row)
        }

        // Compute column widths so headers and values line up roughly.
        var widths: [Int] = headers.map { $0.count }
        for row in rows {
            for (c, cell) in row.enumerated() where c < widths.count {
                widths[c] = Swift.max(widths[c], cell.count)
            }
        }

        let indexStrings = (0..<displayRows).map { "\($0)" }
        let indexWidth = Swift.max(indexStrings.last?.count ?? 1, 1)
        let indexPad = String(repeating: " ", count: indexWidth)

        // Right-align every cell to keep numeric columns clean; the leftmost
        // word column reads fine right-aligned at typical lengths.
        func pad(_ s: String, width: Int) -> String {
            if s.count >= width { return s }
            return String(repeating: " ", count: width - s.count) + s
        }

        var lines: [String] = []
        let headerCells = zip(headers, widths).map { pad($0, width: $1) }
        lines.append(indexPad + "  " + headerCells.joined(separator: "  "))

        for r in 0..<displayRows {
            let indexLabel = pad(indexStrings[r], width: indexWidth)
            let cells = zip(rows[r], widths).map { pad($0, width: $1) }
            lines.append(indexLabel + "  " + cells.joined(separator: "  "))
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Internal scoring

    /// Scores every entry except those in `exclude` against `target` by
    /// cosine similarity, returns the top `k` sorted descending.
    private func topMatches(
        target: [Double],
        exclude: Set<String>,
        k: Int
    ) -> [(rank: Int, word: String, score: Double)] {
        guard k > 0 else { return [] }
        var scored: [(word: String, score: Double)] = []
        scored.reserveCapacity(vectors.count)
        for (word, vector) in vectors {
            if exclude.contains(word) { continue }
            scored.append((word: word, score: vector.cosineOfAngle(with: target)))
        }
        scored.sort { $0.score > $1.score }
        let limit = Swift.min(k, scored.count)
        var output: [(rank: Int, word: String, score: Double)] = []
        output.reserveCapacity(limit)
        for i in 0..<limit {
            output.append((rank: i + 1, word: scored[i].word, score: scored[i].score))
        }
        return output
    }
}
