// Title: Train Test and Score a Regression
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
//
// summary() returns a typed RegressionSummary with coefficients,
// standard errors, t-statistics, p-values, and confidence intervals —
// the inference surface that says whether a slope is real or noise.

// The California Housing districts from example 11. One feature, median
// income (tens of thousands of USD), predicts median house value (USD) —
// the pair example 11 found most strongly correlated.
guard let housing = Dataset.californiaHousing else {
    print("Couldn't load Dataset.californiaHousing.")
    exit(1)
}

let data = housing.toPanel()

// 30% of rows held out for testing. Same seed = same split every run.
let (train, test) = data.trainTestSplit(testRatio: 0.3, seed: 42)

print("train rows:", train.shape.rows)
print("test rows: ", test.shape.rows)
print()

let trainFeatures = train.toMatrix(columns: ["median_income"])
let trainTargets  = train["median_house_value"]
let testFeatures  = test.toMatrix(columns: ["median_income"])
let testTargets   = test["median_house_value"]

let model = try LinearRegression.fit(features: trainFeatures, targets: trainTargets)

// The fit is a row of coefficients, and equation() writes them out as a
// plain formula — intercept first, then the dollars of house value each
// unit of median income adds. A model you can read by hand is not a black box.
print("fitted model:", model.equation())
print()

// Score on held-out test data — this is the honest measure of generalization.
let predictions = model.predict(testFeatures)
let r2 = predictions.rSquared(actual: testTargets)

print("R² on held-out test set:", String(format: "%.3f", r2))
print()

// Inference on the training data — RegressionSummary tells us whether
// the slope is statistically distinguishable from zero, not just whether
// the fit is good.
let report = try model.summary(features: trainFeatures, targets: trainTargets)
print(report)
