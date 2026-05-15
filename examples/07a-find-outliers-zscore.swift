// Title: Find Outliers with a Z-Score Mask
//
// outlierMask returns a [Bool] flagging values more than N standard
// deviations from the mean. trueIndices converts the mask to positions
// so the unusual values can be reported with their original index.
//
// One honest caveat: the mean and standard deviation are themselves
// pulled by extreme values. With one large outlier in a small sample,
// the standard deviation inflates and the threshold widens — sometimes
// far enough that the outlier hides itself. The IQR rule (next example)
// is the robust alternative when the data is skewed.

let dailySpending = [42.0, 38.0, 45.0, 41.0, 39.0, 250.0, 43.0, 40.0, 37.0, 44.0]

let mask = dailySpending.outlierMask(threshold: 2.0)
let indices = mask.trueIndices

print("values:             ", dailySpending)
print("outliers at indices:", indices)

for i in indices {
    print("day \(i + 1): \(dailySpending[i])")
}
