// Title: Correlation Between Income and House Value
//
// Pearson correlation measures the linear relationship between two
// numeric variables. Values near +1 mean they move together; values
// near −1 mean they move opposite each other; values near 0 mean no
// linear relationship. Correlation is bounded in [−1, 1], symmetric,
// and unit-free.
//
// Panel.correlationMatrix() computes every pairwise correlation in
// the table at once. The result is a named tuple of column names and
// the N×N matrix of r values.

guard let housing = Dataset.californiaHousing else {
    exit(0)
}

let panel = housing.toPanel()
let result = panel.correlationMatrix()

print("columns:", result.columns)
print()

// Print the matrix in a labeled, scannable form.
for (i, row) in result.matrix.enumerated() {
    let label = result.columns[i].padding(toLength: 20, withPad: " ", startingAt: 0)
    let cells = row.map { String(format: "%6.2f", $0) }
    print(label, cells.joined(separator: " "))
}
print()

// The headline pair: income and median house value.
let income = panel["median_income"]
let value = panel["median_house_value"]
let r = income.correlation(with: value)
print("median_income vs median_house_value:")
print("  r =", String(format: "%.3f", r))
