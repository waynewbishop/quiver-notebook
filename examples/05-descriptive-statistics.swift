// Title: Descriptive Statistics on a Vector
//
// mean(), median(), standardDeviation(), variance(), standardError(),
// and mode() are first-class methods on [Double] — no Panel, no
// Dataset, no wrapper type required. An array of doubles already is
// a vector and already knows the answers.
//
// summary() returns a typed ColumnSummary in one call — count, mean,
// std, the five-number summary, and IQR — printing itself as a labeled
// block. That is the on-ramp for descriptive stats; the individual
// methods are what you reach for when you only need one number.
//
// standardDeviation() and variance() use sample statistics by default
// (ddof = 1), matching the formula in introductory statistics textbooks.
// Pass ddof: 0 when the array represents an entire population rather
// than a sample. standardError() reports how much the sample mean
// itself is expected to wobble — the foundation for inference.

let scores = [78.0, 82.0, 91.0, 67.0, 88.0, 75.0, 94.0, 71.0, 85.0, 79.0]

guard let s = scores.summary(),
      let variance = scores.variance(),
      let se = scores.standardError() else {
    exit(0)
}

print("scores:", scores)
print()

// The full descriptive picture — summary covers count, mean, std,
// min/q1/median/q3/max, and IQR in one labeled block.
print(s)
print()

// Stats summary() does not include — useful when you need just one number.
print("variance:", String(format: "%.3f", variance))
print("std err: ", String(format: "%.3f", se))
print("mode:    ", scores.mode())
