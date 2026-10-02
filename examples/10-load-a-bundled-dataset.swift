// Title: Load and Summarize a Bundled Dataset
//
// Dataset is part of the Quiver Notebook — a convenient way to start
// testing models the moment the editor opens. Dataset.iris is one of
// several curated datasets that ship with the Notebook, ready to use
// by name with no download, no parsing, no setup.
//
// Each dataset hands back a Quiver Panel of values, a description, and
// a table that decodes string labels back to their original names —
// and once we have that Panel, every Quiver capability is one method
// call away.
//
// summary() returns a typed PanelSummary — count, mean, std, min, and
// max for every numeric column — in one call. CustomStringConvertible
// formats it as a labeled table. The "std" column is the sample
// standard deviation (ddof = 1), matching the default for
// standardDeviation() and variance() on a single column.

guard let iris = Dataset.iris else {
    print("Couldn't load Dataset.iris.")
    exit(1)
}

// A Panel is Quiver's named-column container for tabular data — each
// column is a labeled [Double], and rows align across columns.
let panel = iris.toPanel()

print("shape:", panel.shape)
print()

print(panel.head(n: 3))
print()

print(iris.description)
print()

let classes = iris.categoricalMappings["species"] ?? []
print("species classes:", classes)
print()

// species is a label stored as a code (0, 1, 2), so its mean and std
// describe the codes, not the flowers. The four measurement columns
// are the ones worth reading.
print(panel.summary())

// Other bundled datasets, accessed the same way:
//   Dataset.titanic
//   Dataset.californiaHousing
//   Dataset.bikeSharing
//   Dataset.studentPerformance
