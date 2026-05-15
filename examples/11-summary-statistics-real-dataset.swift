// Title: Summary Statistics on a Real Dataset
//
// summary() returns a typed PanelSummary — count, mean, std, min, and
// max for every numeric column — in one call. CustomStringConvertible
// formats it as a labeled table.
//
// The 1990 California census shipped 20,640 housing districts. The
// "std" column is the sample standard deviation (ddof = 1), matching
// the default for standardDeviation() and variance() on a single column.

guard let housing = Dataset.californiaHousing else {
    exit(0)
}

// A Panel is Quiver's named-column container: each column is a [Double]
// and rows align across columns. head() and summary() give an instant
// feel for the data.
let panel = housing.toPanel()

print("rows:", panel.shape.rows, " columns:", panel.shape.columns)
print()
print(panel.summary())
