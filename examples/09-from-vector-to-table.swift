// Title: From a Vector to a Table
//
// A [Double] already is a vector — every Quiver statistic and similarity
// method works on it directly. But sometimes the analysis is bigger than
// one variable, and we want named columns, aligned rows, and a single
// .summary() call across the whole table. That is when a vector
// graduates into a Panel.
//
// toPanel() promotes a flat [Double] into a one-column Panel without
// the array-of-tuples ceremony. From there, the rest of the Panel API
// is available: head(), summary(), trainTestSplit(), correlationMatrix().

// Reaction times (ms) from a single subject across 30 trials.
let reactionTimes: [Double] = [
    312, 298, 305, 287, 320, 294, 301, 315, 289, 308,
    297, 311, 282, 319, 303, 296, 285, 309, 314, 293,
    300, 317, 290, 306, 313, 288, 304, 298, 316, 295
]

// One method call promotes the [Double] into a Panel column named
// "reaction_ms". The numbers do not change — what changes is the API
// surface available to us.
let panel = reactionTimes.toPanel("reaction_ms")

print("shape:", panel.shape)
print()
print(panel.head(n: 5))
print()

// Now Panel-level tooling works. summary() returns a typed PanelSummary
// across every column — here, just the one.
print(panel.summary())
print()

// The same vector statistics still work on the raw array. The lift is
// view-only: identical numbers, two API surfaces.
print("vector mean: ", String(format: "%.2f", reactionTimes.mean() ?? 0))
print("vector std:  ", String(format: "%.2f", reactionTimes.standardDeviation() ?? 0))
