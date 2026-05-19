// Title: The Central Limit Theorem in Action
//
// The Central Limit Theorem says that when we average many independent
// observations, the distribution of the sample mean approaches a normal
// (bell-shaped) distribution regardless of the population's shape, as
// long as the population has finite variance.
//
// To make that visible: build a heavily skewed population from an
// exponential distribution (most values small, long right tail), then
// draw a thousand small samples from it and record the mean of each.
// The population is obviously not bell-shaped — but the distribution
// of sample means is.

// Seeded so the histogram comes out identically on every run.
var rng = SeededRandomNumberGenerator(seed: 42)

// Build a skewed population: rate = 0.5, so the population mean is 2.0.
let population = [Double].randomExponential(10_000, rate: 0.5, using: &rng)

guard let popMean = population.mean(),
      let popStd = population.standardDeviation() else {
    exit(0)
}

print("population:")
print("  mean:", String(format: "%.3f", popMean), "(theoretical: 2.000)")
print("  std: ", String(format: "%.3f", popStd))
print()
print("  shape — 5-bin histogram:")
for bin in population.histogram(bins: 5) {
    let mid = String(format: "%6.2f", bin.midpoint)
    print("    midpoint:\(mid)  count: \(bin.count)")
}
print()

// Draw 1,000 samples of size 50 and record the mean of each.
let sampleMeans = population.samplingDistributionOfMean(
    sampleSize: 50,
    iterations: 1000,
    seed: 42
)

guard let meansMean = sampleMeans.mean(),
      let meansStd = sampleMeans.standardDeviation() else {
    exit(0)
}

print("distribution of 1,000 sample means (n = 50 each):")
print("  mean:", String(format: "%.3f", meansMean), "(matches population mean)")
print("  std: ", String(format: "%.3f", meansStd), "(the standard error)")
print()
print("  shape — 5-bin histogram:")
for bin in sampleMeans.histogram(bins: 5) {
    let mid = String(format: "%6.2f", bin.midpoint)
    print("    midpoint:\(mid)  count: \(bin.count)")
}
