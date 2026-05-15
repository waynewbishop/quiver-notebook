// Title: Find Outliers with the IQR Rule
//
// The IQR rule is the robust alternative to z-score outlier detection.
// Q1 and Q3 split the data into quarters, and IQR = Q3 − Q1 is the
// spread of the middle 50%. Anything below Q1 − 1.5·IQR or above
// Q3 + 1.5·IQR is an outlier — the same Tukey rule used to draw the
// whiskers of a box plot.
//
// Quartiles are robust statistics: a single huge value cannot pull
// them the way it pulls the mean and standard deviation. That makes
// this rule the right default for skewed real-world data.

let dailySpending = [42.0, 38.0, 45.0, 41.0, 39.0, 250.0, 43.0, 40.0, 37.0, 44.0]

guard let q = dailySpending.quartiles() else {
    exit(0)
}

let lowerFence = q.q1 - 1.5 * q.iqr
let upperFence = q.q3 + 1.5 * q.iqr

let mask = dailySpending.isLessThan(lowerFence)
    .or(dailySpending.isGreaterThan(upperFence))
let indices = mask.trueIndices

print(q)
print()
print("lower fence:", String(format: "%.2f", lowerFence))
print("upper fence:", String(format: "%.2f", upperFence))
print()
print("values:             ", dailySpending)
print("outliers at indices:", indices)

for i in indices {
    print("day \(i + 1): \(dailySpending[i])")
}
