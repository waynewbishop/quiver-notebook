// Title: Evaluating a Binary Classifier
//
// Once a classifier predicts labels, the evaluation work is the same
// regardless of which model produced them. confusionMatrix() reports
// the four binary outcomes (TP, FP, TN, FN) plus accuracy.
// classificationReport() returns a typed ClassificationReport with
// per-class precision, recall, F1, and support — the same shape an
// analyst would write by hand.
//
// Here the data is the Titanic disaster manifest: 889 passengers,
// each labeled with whether they survived. The features include
// class, sex, family size, and fare. The model is the same KNN from
// the previous example; what is new is the evaluation surface.

guard let titanic = Dataset.titanic else {
    exit(0)
}

let panel = titanic.toPanel()

// Drop Age and Embarked because they contain missing values that would
// derail this example's evaluation focus. The five features below have
// no NaNs and capture most of the survival signal.
let featureColumns = ["Pclass", "Sex", "SibSp", "Parch", "Fare"]

let (train, test) = panel.trainTestSplit(testRatio: 0.3, seed: 42)

let trainFeatures = train.toMatrix(columns: featureColumns)
let testFeatures  = test.toMatrix(columns: featureColumns)
let trainLabels   = train.labels("Survived")
let testLabels    = test.labels("Survived")

let model = KNearestNeighbors.fit(features: trainFeatures, labels: trainLabels, k: 5)
let predictions = model.predict(testFeatures)

// Confusion matrix: TP / FP / TN / FN counts plus accuracy.
let cm = predictions.confusionMatrix(actual: testLabels)
print(cm)
print()

print("precision:", cm.precision.map { String(format: "%.3f", $0) } ?? "undefined")
print("recall:   ", cm.recall.map { String(format: "%.3f", $0) } ?? "undefined")
print("f1Score:  ", cm.f1Score.map { String(format: "%.3f", $0) } ?? "undefined")
print()

// classificationReport returns a typed ClassificationReport — per-class
// metrics, accuracy, and macro/weighted averages in one structured value.
print(predictions.classificationReport(actual: testLabels))
