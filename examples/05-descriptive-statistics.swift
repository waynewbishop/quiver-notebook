// Title: Descriptive Statistics on a Vector
//
// mean(), median(), std(), variance(), and quartiles() are first-class
// methods on [Double] — no Panel, no Dataset, no wrapper type required.
// An array of doubles already is a vector and already knows the answers.
//
// Quiver's std() and variance() use population statistics by default
// (ddof = 0). Pass ddof: 1 when the sample-statistics convention is
// what the calculation needs.

let scores = [78.0, 82.0, 91.0, 67.0, 88.0, 75.0, 94.0, 71.0, 85.0, 79.0]

print("scores:  ", scores)
print("count:   ", scores.count)
print("mean:    ", String(format: "%.3f", scores.mean() ?? 0))
print("median:  ", String(format: "%.3f", scores.median() ?? 0))
print("std:     ", String(format: "%.3f", scores.std() ?? 0))
print("variance:", String(format: "%.3f", scores.variance() ?? 0))
print()

// quartiles() returns a five-number summary plus the IQR.
if let q = scores.quartiles() {
    print(q)
}
