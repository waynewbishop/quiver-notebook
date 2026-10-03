# Quiver Notebook examples

Twenty-three focused examples that walk the surface of Quiver from a single line of vector arithmetic to word-embedding analogies. Each file is a complete, runnable program — open one in the Notebook and the result prints in seconds.

The order is a curriculum, not a catalog. Read them top to bottom and the framework teaches itself.

These examples teach the core arc, not the whole library. For the rest of the surface, see the [Quiver Cookbook](https://github.com/waynewbishop/quiver-cookbook) and the [Quiver documentation](https://waynewbishop.github.io/quiver/documentation/quiver/).

Expected output appears as a comment only where a specific number is the point of the example. Exploratory examples leave the output to the run.

---

## Vectors

The starting point: a `[Double]` is already a vector, and Quiver's first surface is the operations that work on it directly.

| File | What it shows |
| --- | --- |
| `01-fahrenheit-to-celsius.swift` | Scalar broadcasting reads like the formula |
| `02-vector-addition.swift` | Element-wise operations and the named-method convention |
| `03-normalize-a-vector.swift` | Magnitude and unit vectors |
| `04-cosine-similarity.swift` | The angle-based similarity behind every embedding model |

## Describing Data

Once the vector is a measured thing, the next questions are about its shape. `summary()` is the on-ramp; the individual methods are what you reach for when you only need one number.

| File | What it shows |
| --- | --- |
| `05-descriptive-statistics.swift` | The full descriptive surface — `summary()`, plus variance, std error, mode |
| `06-histogram-and-quartiles.swift` | Histogram bins and the `Quartiles` struct |
| `07-outlier-detection.swift` | Z-score rule vs. IQR rule, side by side |
| `08-frequency-table.swift` | `distinctCounts()` and `mode()` on a discrete column, where a count by value shows what the mean hides |

## Working with Panels

When a column is not enough, `Panel` adds named columns and aligned rows. Every Quiver capability on a `[Double]` also works on a Panel column.

| File | What it shows |
| --- | --- |
| `09-from-vector-to-table.swift` | Promoting a `[Double]` into a one-column Panel |
| `10-load-a-bundled-dataset.swift` | `Dataset.iris`, the bundled-data on-ramp, and `panel.summary()` |
| `11-correlation-between-columns.swift` | Pearson r and the full correlation matrix |
| `12-percent-change.swift` | Time-series primitives on real bike-sharing data |

## Reasoning Under Uncertainty

Description is what the data says; inference is what the data implies. Three examples build the inferential vocabulary: sampling distributions, confidence intervals, and hypothesis tests.

| File | What it shows |
| --- | --- |
| `13-central-limit-theorem.swift` | Random distributions and the sampling distribution of the mean |
| `14-confidence-interval.swift` | `Distributions.t.quantile` and `standardError()` |
| `15-one-sample-t-test.swift` | A one-sample t-test with `Distributions.t.cdf`, and why it agrees with the interval |

## Models and Embeddings

Quiver ships several models — linear regression, KNN, K-Means — alongside the evaluation surface every model shares. The closer is the highest-WOW moment in the library.

| File | What it shows |
| --- | --- |
| `16-train-test-and-score-a-regression.swift` | `LinearRegression` with full `RegressionSummary` inference |
| `17-classify-with-knn.swift` | `KNearestNeighbors` on the Iris dataset |
| `18-evaluating-a-binary-classifier.swift` | `ConfusionMatrix` and `ClassificationReport` on Titanic |
| `19-kmeans-clustering.swift` | `KMeans` unsupervised clustering |
| `20-explore-word-embeddings.swift` | GloVe 50d — `king − man + woman ≈ queen` |
| `21-retrieval-augmented-generation.swift` | Chunk a passage, embed each fragment, retrieve the top match for a question by meaning |
| `22-gate-a-retrieval.swift` | Read a retrieval's score field — mean, spread, top score, top z — and decide with `isAboveGate` whether the top hit is worth handing to a model |

## Concurrency

A fit can be heavy. Swift's structured concurrency runs several at once with no extra library, and a Quiver model is an immutable value type — safe to hand back across the task boundary.

| File | What it shows |
| --- | --- |
| `23-structured-concurrency-with-kmeans.swift` | `Task.detached` runs a `KMeans` fit off the calling context; `await` returns the model |
