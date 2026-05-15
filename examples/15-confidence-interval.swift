// Title: Building a Confidence Interval
//
// The sample mean is one number, but the truth is a range. A 95%
// confidence interval is the most-used summary of that range: an
// interval around the sample mean inside which the population mean
// most plausibly lives.
//
// The formula is sample_mean ± t_critical · standard_error, where
// t_critical is the quantile of the t-distribution at the chosen
// confidence level and degrees of freedom (n − 1).

// Reaction times (ms) for a single subject across 30 trials.
let reactionTimes: [Double] = [
    312, 298, 305, 287, 320, 294, 301, 315, 289, 308,
    297, 311, 282, 319, 303, 296, 285, 309, 314, 293,
    300, 317, 290, 306, 313, 288, 304, 298, 316, 295
]

let n = reactionTimes.count
let df = Double(n - 1)

guard let mean = reactionTimes.mean(),
      let se = reactionTimes.standardError(),
      let tCritical = Distributions.t.quantile(p: 0.975, df: df) else {
    exit(0)
}

let margin = tCritical * se
let lower = mean - margin
let upper = mean + margin

print("n:              ", n)
print("sample mean:    ", String(format: "%.3f", mean))
print("standard error: ", String(format: "%.3f", se))
print("t (df=\(Int(df)), 0.975):", String(format: "%.3f", tCritical))
print()
print("95% confidence interval:")
print("  [\(String(format: "%.3f", lower)), \(String(format: "%.3f", upper))]")
