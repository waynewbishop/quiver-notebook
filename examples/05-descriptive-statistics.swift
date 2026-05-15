// Title: Descriptive Statistics on a Vector
//
// mean(), median(), standardDeviation(), variance(), standardError(),
// and mode() are first-class methods on [Double] — no Panel, no
// Dataset, no wrapper type required. An array of doubles already is
// a vector and already knows the answers.
//
// standardDeviation() and variance() use sample statistics by default
// (ddof = 1), matching the formula in introductory statistics textbooks.
// Pass ddof: 0 when the array represents an entire population rather
// than a sample. standardError() reports how much the sample mean
// itself is expected to wobble — the foundation for inference.

let scores = [78.0, 82.0, 91.0, 67.0, 88.0, 75.0, 94.0, 71.0, 85.0, 79.0]

print("scores:  ", scores)
print("count:   ", scores.count)
print("mean:    ", String(format: "%.3f", scores.mean() ?? 0))
print("median:  ", String(format: "%.3f", scores.median() ?? 0))
print("std:     ", String(format: "%.3f", scores.standardDeviation() ?? 0))
print("variance:", String(format: "%.3f", scores.variance() ?? 0))
print("std err: ", String(format: "%.3f", scores.standardError() ?? 0))
print("mode:    ", scores.mode())
print()

// summary() returns a typed ColumnSummary — count, mean, std, the
// five-number summary, and IQR — in one call. CustomStringConvertible
// does the formatting.
if let s = scores.summary() {
    print(s)
}
