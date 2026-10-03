// Title: Testing a Claimed Mean
//
// A confidence interval asks where the population mean plausibly
// lives. A one-sample t-test asks the reverse question: given a claimed
// value, is the sample far enough from it that the claim becomes hard
// to believe?
//
// The test statistic is t = (sample_mean − claimed_mean) / standard_error,
// the distance between sample and claim measured in standard errors.
// The p-value is the probability of landing at least that far away, in
// either direction, if the claim were true: 2 · (1 − cdf(|t|)) on the
// t-distribution with n − 1 degrees of freedom.

// The same 30 reaction times as example 14. Suppose the reference value
// for this task is 300 ms. Is this subject distinguishable from it?
let reactionTimes: [Double] = [
    312, 298, 305, 287, 320, 294, 301, 315, 289, 308,
    297, 311, 282, 319, 303, 296, 285, 309, 314, 293,
    300, 317, 290, 306, 313, 288, 304, 298, 316, 295
]

let claimedMean = 300.0
let n = reactionTimes.count
let df = Double(n - 1)

guard let mean = reactionTimes.mean(),
      let se = reactionTimes.standardError() else {
    print("Couldn't compute the mean or standard error.")
    exit(1)
}

let t = (mean - claimedMean) / se

guard let cdf = Distributions.t.cdf(x: abs(t), df: df) else {
    print("Couldn't compute the t-distribution CDF.")
    exit(1)
}

let pValue = 2.0 * (1.0 - cdf)

print("claimed mean:   ", claimedMean)
print("sample mean:    ", String(format: "%.3f", mean))
print("standard error: ", String(format: "%.3f", se))
print("t (df=\(Int(df))):       ", String(format: "%.3f", t))
print("p-value:        ", String(format: "%.3f", pValue))
print()

if pValue < 0.05 {
    print("Reject the claim at the 5% level.")
} else {
    print("Not distinguishable from \(Int(claimedMean)) ms at the 5% level.")
}

// 300 ms sits inside the 95% interval from example 14, [298.077, 306.256],
// and that is no coincidence: a two-sided test at the 5% level rejects
// exactly the claimed values that fall outside the 95% interval. The
// interval and the test are two readings of the same calculation.
