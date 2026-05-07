// Title: Summary Statistics on a Real Dataset
//
// One call gives the full statistical profile of every numeric column
// in a real dataset. The 1990 California census shipped 20,640 housing
// districts; we get count, mean, std, min, and max for all of it
// without writing a loop. Quiver's std is population (ddof = 0); pass
// ddof: 1 on a single column when sample std is what is needed.

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
