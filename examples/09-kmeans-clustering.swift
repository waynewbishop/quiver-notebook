// Title: K-Means Clustering with a Fixed Seed
//
// K-Means groups unlabeled points into k clusters. Passing a seed makes
// the initial centroid placement deterministic — rerun the same code and
// get the same clusters every time.
//
// The fitted model conforms to CustomStringConvertible, so print(model)
// gives a clean summary. Each Cluster also prints cleanly and conforms
// to Sequence, so its points can be iterated with for-in.

// Unlabeled 2D data — three natural groups.
let data: [[Double]] = [
    [1.0, 2.0], [1.5, 1.8], [1.2, 2.1],    // group A
    [5.0, 5.0], [5.5, 4.8], [4.8, 5.2],    // group B
    [9.0, 8.0], [8.5, 8.5], [9.2, 7.8]     // group C
]

let model = KMeans.fit(data: data, k: 3, seed: 1)

// CustomStringConvertible — a one-line summary of the fitted model.
print(model)
print()

// Each cluster prints cleanly. Iterating with for-in uses Sequence
// conformance on the cluster itself if you want to walk its points.
let clusters = model.clusters(from: data)
for cluster in clusters {
    print(cluster)
}
print()

// Individual properties remain available for detailed inspection.
print("labels:", model.labels)
