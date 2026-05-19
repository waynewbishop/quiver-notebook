// Title: Find Outliers — Z-Score and IQR Rule Side by Side
//
// Outlier detection has two go-to rules. The z-score rule flags any
// value more than N standard deviations from the mean. The IQR rule
// (also called the Tukey rule) flags anything below Q1 − 1.5·IQR or
// above Q3 + 1.5·IQR — the same fences a box plot uses to draw its
// whiskers.
//
// They disagree on purpose. Mean and standard deviation are themselves
// pulled by extreme values, so a single huge outlier in a small sample
// can inflate the standard deviation enough that the threshold widens
// past the outlier itself — and the outlier hides. Quartiles do not
// move that way. With one inflated value in ten, the IQR rule sees
// the outlier; the z-score rule sometimes does not. That is the
// lesson of running them side by side.

let dailySpending = [42.0, 38.0, 45.0, 41.0, 39.0, 250.0, 43.0, 40.0, 37.0, 44.0]

print("values:", dailySpending)
print()

// Z-score rule: flag values more than 2 standard deviations from the mean.
// outlierMask returns a [Bool] aligned with the input; trueIndices
// converts the mask back to positions.
let zMask = dailySpending.outlierMask(threshold: 2.0)
let zIndices = zMask.trueIndices
print("z-score rule (threshold = 2σ):")
print("  outliers at indices:", zIndices)
for i in zIndices {
    print("    index \(i): \(dailySpending[i])")
}
print()

// IQR rule: flag values outside [Q1 − 1.5·IQR, Q3 + 1.5·IQR].
// Boolean-mask composition (.or) builds the fence test from two
// element-wise comparisons, no manual loop required.
guard let q = dailySpending.quartiles() else {
    exit(0)
}

let lowerFence = q.q1 - 1.5 * q.iqr
let upperFence = q.q3 + 1.5 * q.iqr

let iqrMask = dailySpending.isLessThan(lowerFence)
    .or(dailySpending.isGreaterThan(upperFence))
let iqrIndices = iqrMask.trueIndices

print(q)
print()
print("IQR rule (Tukey, 1.5·IQR fences):")
print("  lower fence:", String(format: "%.2f", lowerFence))
print("  upper fence:", String(format: "%.2f", upperFence))
print("  outliers at indices:", iqrIndices)
for i in iqrIndices {
    print("    index \(i): \(dailySpending[i])")
}
