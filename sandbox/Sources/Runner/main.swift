import Quiver
import Foundation
setvbuf(stdout, nil, _IOLBF, 0)  // keeps printed lines when the program crashes
// --- user code begins ---

// Training data: square footage → price
let features: [[Double]] = [[1000], [1500], [2000], [2500], [3000]]
let targets = [150000.0, 200000.0, 260000.0, 310000.0, 370000.0]

// Fit, predict, evaluate — three lines
let model = try LinearRegression.fit(features: features, targets: targets)
let predictions = model.predict(features)
let r2 = predictions.rSquared(actual: targets)  // 0.99+

// Generate a trend line for charting
let trendX = Array.linspace(start: 500.0, end: 3500.0, count: 50)
let trendY = model.predict(trendX)  // parallel arrays ready for Swift Charts

print(model.equation())
// --- user code ends ---