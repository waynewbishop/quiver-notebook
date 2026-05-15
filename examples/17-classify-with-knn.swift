// Title: Classify Iris with K-Nearest Neighbors
//
// KNN is the most teachable classifier — for each new point, look at
// the k nearest training points and take a vote. No abstract decision
// boundary, no iterative fit. The same train/test split idea from the
// previous example carries over: hold out a slice, fit on the rest,
// score on the slice the model never saw.
//
// To keep the metrics surface tight, we collapse Iris's three species
// into a binary problem: is this flower setosa, or not? The same code
// shape extends to the multi-class case.

guard let iris = Dataset.iris else {
    exit(0)
}

let panel = iris.toPanel()

// Hold out 30% of rows for testing. Same seed = same split every run.
let (train, test) = panel.trainTestSplit(testRatio: 0.3, seed: 42)

let featureColumns = ["sepal_length", "sepal_width", "petal_length", "petal_width"]

let trainFeatures = train.toMatrix(columns: featureColumns)
let testFeatures  = test.toMatrix(columns: featureColumns)

// Recode species: 1 means setosa, 0 means anything else.
let trainLabels = train.labels("species").map { $0 == 0 ? 1 : 0 }
let testLabels  = test.labels("species").map { $0 == 0 ? 1 : 0 }

let model = KNearestNeighbors.fit(features: trainFeatures, labels: trainLabels, k: 5)
print(model)
print()

let predictions = model.predict(testFeatures)

// Accuracy: fraction of test rows the model labeled correctly.
let accuracy = predictions.accuracy(actual: testLabels, positiveLabel: 1)
print("accuracy:", String(format: "%.3f", accuracy))
print()

// classificationReport prints precision, recall, F1, and support
// for the positive class alongside overall accuracy.
print(predictions.classificationReport(actual: testLabels))
