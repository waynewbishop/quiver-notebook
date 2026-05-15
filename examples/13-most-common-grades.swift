// Title: Most Common Grades in a Distribution
//
// mean() and median() report a center; quartiles() report a spread.
// Sometimes the question we actually have is simpler: which value
// shows up most often? mode() answers that — and unlike most languages'
// equivalents, Quiver's mode() returns [Element], not a single value.
//
// The reason is honest: a distribution can be bimodal. Two values can
// tie for the highest frequency, and a scalar return would silently pick
// one and pretend the other did not exist. Returning [Element] makes the
// "there are two modes" answer first-class.

guard let students = Dataset.studentPerformance,
      let finalGrades = students["G3"] else {
    exit(0)
}

print("count:    ", finalGrades.count)
print("mean:     ", String(format: "%.2f", finalGrades.mean() ?? 0))
print("median:   ", String(format: "%.2f", finalGrades.median() ?? 0))
print()

// Final grades are 0–20 integers in this dataset. mode() returns every
// value tied for highest frequency.
let modes = finalGrades.mode()
print("mode(s):", modes)

if modes.count > 1 {
    print()
    print("This distribution is multimodal — \(modes.count) values share the highest frequency.")
}
