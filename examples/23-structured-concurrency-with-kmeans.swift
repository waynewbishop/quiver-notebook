// Title: Structured Concurrency with KMeans
//
// A model fit can be heavy, and you rarely want it blocking the context that
// asked for it. Task.detached starts an independent task that runs on its own,
// and await suspends until it hands the result back — no extra library needed.
//
// Quiver composes with this cleanly because a fitted model is an immutable
// value type — it crosses the task boundary with nothing to synchronize. The
// concurrency is the Swift language; what Quiver adds is a model that is safe
// to pass across it.

// Train off the calling context. Task.detached starts an independent task
// that runs on its own — the right choice for a long-running fit.
func trainClusters(from data: [[Double]]) async -> KMeans {
    return await Task.detached {
        KMeans.fit(data: data, k: 2, seed: 42)   // the work runs inside the detached task
    }.value                                       // .value awaits the task and hands the model back
}

// Four 2-D points: two near the origin, two out at (8,8) — two natural clusters.
// KMeans needs at least k points, so a single sample won't form 2 clusters.
let examples = [
    [1.0, 2.0],
    [1.5, 1.8],
    [8.0, 8.0],
    [9.0, 8.5],
]


// await suspends here until the detached task finishes, then receives the fitted model.
let results = await trainClusters(from: examples)
print(results)

// Output:
// KMeans: 2 clusters, 4 points, converged in 2 iterations (inertia: 0.77)
