// Title: Train/Test Split and Linear Regression
//
// Fitting a model on the data you already have overstates how well it
// will do on new data. The standard fix is to hold out a random slice
// as a test set, fit only on the training slice, then score the model
// against the held-out rows.
//
// Panel.trainTestSplit keeps features and labels aligned across columns
// — the same rows go into the training Panel and the same rows into the
// test Panel. Passing a seed makes the split reproducible, which matters
// for grading, debugging, and any reporting of results.

// House size (sq ft) and price (USD thousands).
let data = Panel([
    ("size",  [1000.0, 1200.0, 1500.0, 1800.0, 2000.0, 2200.0, 2500.0, 2800.0, 3000.0, 3200.0]),
    ("price", [180.0, 210.0, 260.0, 295.0, 325.0, 360.0, 410.0, 455.0, 485.0, 515.0])
])

// 30% of rows held out for testing. Same seed = same split every run.
let (train, test) = data.trainTestSplit(testRatio: 0.3, seed: 42)

print("train rows:", train.shape.rows)
print("test rows: ", test.shape.rows)
print()

let trainFeatures = train.toMatrix(columns: ["size"])
let trainTargets  = train["price"]
let testFeatures  = test.toMatrix(columns: ["size"])
let testTargets   = test["price"]

let model = try LinearRegression.fit(features: trainFeatures, targets: trainTargets)

let predictions = model.predict(testFeatures)
let r2 = predictions.rSquared(actual: testTargets)

print("R² on held-out test set:", r2)
print()
print(model)
