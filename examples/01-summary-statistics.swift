// Title: Summary Statistics
//
// Describe a small dataset in one pass. Quiver adds descriptive statistics
// as extensions on any [Double], so the same call signatures work whether
// the data comes from a sensor, a spreadsheet, or a database.

let scores = [72.0, 85.0, 91.0, 68.0, 77.0, 88.0, 95.0, 82.0, 79.0, 84.0]

print("count: ", scores.count)
print("mean:  ", scores.mean() ?? 0)
print("median:", scores.median() ?? 0)
print("std:   ", scores.std() ?? 0)

let q = scores.quartiles()
print("quartiles: min=\(q?.min ?? 0) q1=\(q?.q1 ?? 0) median=\(q?.median ?? 0) q3=\(q?.q3 ?? 0) max=\(q?.max ?? 0)")
