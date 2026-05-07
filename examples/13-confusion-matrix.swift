// Title: Classification Metrics from Predictions
//
// Once a classifier predicts labels, the evaluation work is the same
// regardless of which model produced them. Both methods below take an
// [Int] of predicted labels and an [Int] of actual labels — no model
// dependency, no glue code. confusionMatrix() reports the four binary
// outcomes; classificationReport() computes per-class precision, recall,
// F1, and support in one call.

let predictions = [1, 0, 1, 1, 0, 0, 1, 0, 1, 1]
let actual      = [1, 0, 0, 1, 0, 1, 1, 0, 1, 0]

// Confusion matrix: TP / FP / TN / FN counts plus accuracy.
let cm = predictions.confusionMatrix(actual: actual)
print(cm)
print()

print("precision:", cm.precision.map { String(format: "%.3f", $0) } ?? "undefined")
print("recall:   ", cm.recall.map { String(format: "%.3f", $0) } ?? "undefined")
print("f1Score:  ", cm.f1Score.map { String(format: "%.3f", $0) } ?? "undefined")
print()

// classificationReport() formats per-class metrics, accuracy, and
// macro/weighted averages — the same shape an analyst would write by hand.
print(predictions.classificationReport(actual: actual))
