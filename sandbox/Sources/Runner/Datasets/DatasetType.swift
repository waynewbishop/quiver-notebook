import Quiver

/// A bundled dataset wrapping a Quiver `Panel` of numeric columns.
///
/// Strings in the source CSV are alphabetically encoded to `Double` indices and
/// the original ordered class names are stashed in `categoricalMappings` so
/// students can decode predictions back to label strings. Missing values are
/// preserved as `Double.nan` rather than mean-imputed.
public struct Dataset: Sendable {
    /// Short identifier — `"iris"`, `"titanic"`, etc., or for `load(path:)`,
    /// the input filename without its extension.
    public let name: String

    /// Human-readable summary of the dataset's origin, row count, columns, and
    /// any cleaning that was applied. For example, the bundled `iris` dataset's
    /// description records that it holds 150 rows across three species, four
    /// numeric features, and was originally published by R. A. Fisher in 1936.
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
