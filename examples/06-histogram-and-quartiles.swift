// Title: Distribution: Histogram and Quartiles
//
// Mean and median tell us where data sits. Histogram and quartiles tell
// us how it is spread. histogram() returns equal-width bins as
// (midpoint, count) tuples — chart-ready and scan-ready. quartiles()
// returns the five-number summary, and percentile() returns the value
// at any cut point we choose.

let responseTimes = [
    12.0, 15.0, 11.0, 18.0, 14.0, 16.0, 13.0, 17.0, 19.0, 22.0,
    14.0, 16.0, 15.0, 20.0, 25.0, 13.0, 18.0, 17.0, 21.0, 28.0,
    35.0, 42.0, 19.0, 24.0, 31.0, 16.0, 22.0, 38.0, 55.0, 89.0
]

print("response times — 5-bin histogram (ms):")
for bin in responseTimes.histogram(bins: 5) {
    let midpoint = String(format: "%6.1f", bin.midpoint)
    print("  midpoint:\(midpoint)  count: \(bin.count)")
}
print()

if let q = responseTimes.quartiles() {
    print(q)
}
print()

// percentile() answers "the slowest 10% of requests took at least how long?"
let p90 = responseTimes.percentile(90.0) ?? 0
print("90th percentile:", String(format: "%.1f", p90), "ms")
