// Title: Frequency Table for a Discrete Column
//
// summary() is the right tool for continuous-feeling data — heights,
// prices, sensor readings — where the five-number summary captures
// the shape. For a column with a small, discrete support — grades 0–20,
// dice rolls, ratings 1–5 — the more honest tool is a frequency table.
// Mean and median can blur clumps that the eye would catch immediately
// in a count by value.
//
// distinctCounts() returns (value, count) tuples sorted ascending by
// value. Re-sorting by count puts the most frequent values first —
// and the mode falls out as the top row.

guard let students = Dataset.studentPerformance,
      let finalGrades = students["G3"],
      let summary = finalGrades.summary() else {
    exit(0)
}

print(summary)
print()

// Sort the (value, count) pairs by count descending — top of the
// table is the most-common value, which is also the mode.
let byFrequency = finalGrades.distinctCounts()
    .sorted { $0.count > $1.count }

print("frequency table (top 6 by count):")
for entry in byFrequency.prefix(6) {
    let value = Int(entry.value).description.padding(toLength: 3, withPad: " ", startingAt: 0)
    let bar = String(repeating: "█", count: entry.count / 4)
    print("  \(value)  \(entry.count)  \(bar)")
}
print()

// mode() returns the same answer as an array — bimodal distributions
// return more than one value, so the return type is [Element] rather
// than a single scalar that would silently hide a tie.
let modes = finalGrades.mode()
print("mode(s):", modes)

// The most-common grade is the top row of the table. The interesting
// fact this dataset hands back is the third row: a clump of zeros that
// the mean alone would average away. Looking at the frequency table
// is how that sub-population becomes visible.
