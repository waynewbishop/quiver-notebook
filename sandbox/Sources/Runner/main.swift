import Quiver
import Structures
import Foundation

// --- user code begins ---


guard let glove = Dataset.glove50d else {
    exit(0)
}

// A Panel is Quiver's named-column container for tabular data — each
// column is a labeled [Double], and rows align across columns.
let panel = glove.toPanel()
print(panel.head(n: 3))
print()

// --- user code ends ---