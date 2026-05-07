// Title: Load a Bundled Dataset
//
// Dataset is part of the Quiver Notebook — a convenient way to start
// testing models the moment the editor opens. Dataset.iris is one of
// several curated datasets that ship with the Notebook, ready to use
// by name with no download, no parsing, no setup.
//
// Each dataset hands back a description, a table that decodes string
// labels back to their original names, and a Quiver Panel of values
// — and once we have that Panel, every Quiver capability is one method
// call away.

guard let iris = Dataset.iris else {
    exit(0)
}

// A Panel is Quiver's named-column container for tabular data — each
// column is a labeled [Double], and rows align across columns.
let panel = iris.toPanel()
print(panel.head(n: 3))
print()

print(iris.description)
print()

let classes = iris.categoricalMappings["species"] ?? []
print("species classes:", classes)
print()

print("shape:", panel.shape)

// Other bundled datasets, accessed the same way:
//   Dataset.titanic
//   Dataset.californiaHousing
//   Dataset.bikeSharing
//   Dataset.studentPerformance
