# Quiver Notebook — A browser-based Swift environment for statistics and machine learning 

The Quiver Notebook is a browser-based Swift development environment for writing numerical and machine learning code. It's a lightweight learning tool for working through statistics, linear algebra, and machine learning models in pure Swift.

To start:

1. Clone the repo.
2. Type `swift run` from the macOS terminal.
3. A browser window opens with a Swift editor already wired to two libraries:
   * [Quiver](https://github.com/waynewbishop/quiver) — vectors, matrices, statistics, and machine learning models.
   * [Structures](https://github.com/waynewbishop/bishop-algorithms-swift-package) — the data structures and algorithms behind them.

There is no project to configure, no binaries to install, no account to create, and no service in the loop. Code runs on the same machine that hosts the browser, and the output comes back to the same tab. The entire environment is one repository on disk.

## Features

* **Browser-based Swift editor.**
  * Monaco editor with full Swift syntax highlighting.
  * Cmd/Ctrl + Enter to run.
  * Auto-save to local storage so work persists across refreshes.
  * Copy-to-clipboard for sharing snippets in assignments and messages.

* **Pre-wired two-package stack.**
  * `Quiver` — vectors, matrices, statistics, similarity, machine learning models. Auto-imported in every snippet.
  * `Structures` — heaps, tries, graphs, stacks, queues, binary search trees. One `import Structures` line away.
  * `Foundation` — dates, JSON, file reading, regular expressions. Auto-imported.

* **Bundled datasets.**
  * Classic teaching sets — Iris, Titanic, California Housing, Bike Sharing — accessible by name with no download step.
  * Drop your own `.csv` into the `user/` folder and it appears under `Datasets.user`.
  * Every dataset extracts to a Quiver `Panel` with one call, so the same code transfers to any iOS, watchOS, or visionOS app.

* **Curated examples sidebar.**
  * Ready-to-run snippets covering mean, standard deviation, cosine similarity, linear regression, softmax, k-means.
  * Each example loads into the editor with one click.
  * Educators extend the sidebar by dropping their own `.swift` files into `examples/`.

* **Local-first and private.**
  * Runs on `127.0.0.1` (localhost only) — refuses to start if the bind address is changed.
  * No accounts, no telemetry, no analytics.
  * Pinned Quiver release — every student gets the same known-good version.

## Quick Start

Quiver Notebook runs on the Swift CLI, which is not preinstalled on macOS. Before cloning, confirm Swift 5.9 or newer is available:

```bash
swift --version
```

If the command is missing or the version is older than 5.9, install the Swift CLI from [swift.org/install](https://www.swift.org/install/). The page covers macOS and Linux, and Xcode is not required — you can run the notebook with the standalone toolchain alone. On macOS, Swift also ships with Xcode if it is already installed (`xcode-select --install` for the Command Line Tools), in which case no additional download is needed. Once Swift is in place:

```bash
git clone https://github.com/waynewbishop/quiver-notebook
cd quiver-notebook
swift run
```

Then open [http://localhost:8080](http://localhost:8080) in a browser. The first launch compiles the libraries and the editor framework, which takes a minute or two. Subsequent runs start in seconds. The notebook needs macOS 14+ or Linux with Swift 5.9+.

### Load and inspect a dataset

A `Panel` is Quiver's named-column data structure for tabular data — think of it as a small table where each column is a labeled `[Double]`. Full reference at [Panel](https://waynewbishop.github.io/quiver/documentation/quiver/panel). The bundled datasets are accessible by name and extract to a `Panel` with one call:

```swift
guard let dataset = Datasets.iris else { return }

let panel = dataset.toPanel()
print(dataset.description)
print(panel.head())
```

When coding, the `import Quiver` line is optional because the notebook injects it automatically. `Datasets.iris` returns a ready-to-use bundled dataset; `toPanel()` hands back a Quiver `Panel` we can explore when testing statistical or machine learning models.

### Statistics

A typical workflow is summary statistics followed by outlier detection on the same array:

```swift
let sales = [45.0, 52.0, 48.0, 61.0, 55.0, 58.0, 49.0, 67.0, 145.0, 69.0]

print("mean:", sales.mean() ?? .nan)
print("median:", sales.median() ?? .nan)
print("std:", sales.std() ?? .nan)

let smoothed = sales.rollingMean(window: 3)
let outliers = sales.outlierMask(threshold: 2.0).trueIndices
print("outlier indices:", outliers)
```

### Linear algebra

Magnitude and distance both use the Pythagorean theorem, but they answer different questions. Magnitude asks how far a point is from the origin; distance asks how far one point is from another. Same theorem, different starting points.

```swift
// Magnitude — how far from the origin?
// For [3, 4], that's √(3² + 4²) = 5.0
let position = [3.0, 4.0]
let distanceFromHome = position.magnitude()  // 5.0

// Distance — how far between two points?
// From [1, 2] to [4, 6]: √((4-1)² + (6-2)²) = 5.0
let library = [1.0, 2.0]
let coffeeShop = [4.0, 6.0]
let gap = library.distance(to: coffeeShop)  // 5.0

// Magnitude is just distance from the origin
let origin = [0.0, 0.0]
let proof = origin.distance(to: position)  // 5.0
```

### Train a model

The same pipeline — fit, predict, evaluate — covers every supervised model in Quiver. Linear regression is the simplest:

```swift
// Training data: square footage → price
let features: [[Double]] = [[1000], [1500], [2000], [2500], [3000]]
let targets = [150000.0, 200000.0, 260000.0, 310000.0, 370000.0]

let model = try LinearRegression.fit(features: features, targets: targets)
let predictions = model.predict(features)
let r2 = predictions.rSquared(actual: targets)  // ≈ 0.9988

print("predictions:", predictions)
print("R²:", r2)
```

## Design Philosophy

* **Local-first** — runs entirely on the student's machine, never phones home
* **Frictionless** — clone, `swift run`, write code. No accounts, no setup rituals
* **Two-package discipline** — Quiver and Structures are enough for a college ML course. More libraries would dilute the focus
* **Transparent** — students read the source of everything they use, including this notebook itself
* **Educational** — the tool is built to be inspected, modified, and taught from

## Who this is for

**Students** working through a course, textbook, or self-study get a Swift environment that does numerical work without having to install and configure binaries. **iOS and Apple-platform developers** also receive a focused editor for designing a model or testing ideas. Code that works in the notebook runs unchanged on any Apple platform including iOS, watchOS, or a Swift on Server solution with Vapor.

**Educators** preparing lectures or assignments can also fork the repository, drop their own example files into `examples/`, and distribute the URL to a class. The bundled stack is enough to support an applied linear algebra unit, an introductory descriptive statistics segment, and an applied regression module — the kind of material that fits inside an existing course rather than replacing one. A short supervised-learning survey using k-nearest neighbors, k-means, and naive Bayes is also workable. Topics that depend on logistic regression, gradient descent, regularization, or principal components are not yet covered by the underlying library.

## When to Use Quiver Notebook

* **Teaching a Swift-based ML course** — a pure-Swift classroom environment that runs on every student's machine
* **Running exercises in restricted networks** — classroom environments, exam settings
* **Student self-study** — anyone reading *Swift Algorithms & Data Structures* who wants to experiment alongside the book
* **Prototyping ML for Apple devices** — design a model in pure Swift before dropping it into an iOS, watchOS, or visionOS app
* **Workshops and tutorials** — a shared environment attendees install in under a minute

## Keeping Quiver Current

The notebook ships with a specific Quiver release pinned in `sandbox/Package.resolved`, so every student who clones the repository gets the same known-good version. The footer shows the active version. Pinning is the right default for a course: a class starts and finishes on the same release. New Quiver releases are bundled by us and pushed to the notebook's `main` branch — pull the latest from GitHub when you're ready to move forward, or stay on the version your course started with.

## Running Safely

The Quiver Notebook is local-first by construction. The Vapor server binds to `127.0.0.1`, so only the computer running the notebook can reach it. There are no accounts, no telemetry, and no analytics endpoint — code, output, and errors stay on the machine where they were written. Combined with the pinned Quiver release, this is what makes the tool safe to hand to a class without an IT review.

The Notebook executes Swift with the permissions of the user who launched it, which is the right model for one person on one laptop. If a hosted environment is the goal, please reach out first.

## FAQ

**Will code I write also run in Xcode?** Yes. Every snippet is pure Swift against Quiver and Structures, both of which are ordinary Swift packages. Copy a working snippet into an Xcode project that depends on those packages and it will run unchanged.

**Can I just do all of this in Xcode instead?** Yes — an Xcode project that depends on Quiver and Structures runs the same code the notebook does. What we lose by working in Xcode alone is the bundled dataset library: `Datasets.iris`, `Datasets.titanic`, the `user/` drop folder, and the boot-log catalog all live inside the notebook's sandbox target and are not part of Quiver. We also lose the auto-injected imports, the curated examples sidebar, and the clone-and-distribute model that lets an instructor hand a fork to a class. For shipping an app, Xcode is the right tool.

**Is this pure Swift code or some variant?** Pure Swift. The code written in the editor is the code the Swift compiler sees. The notebook auto-imports Quiver and Foundation so those lines do not need to appear in every snippet, and that is the extent of the work it does on our behalf.

**Why can't I import my own libraries or other Apple frameworks?** The two-package discipline is intentional. Adding more libraries to the sandbox would change what the notebook is — a focused teaching and prototyping environment becomes another general-purpose Swift workspace, which Xcode already does well. For libraries beyond Quiver and Structures, an Xcode project is the right tool. The notebook stays small on purpose.

**Can I build apps with Quiver Notebook?** No. The notebook runs free-form Swift code that prints output to a pane — it is not a project workspace, has no UI canvas, and does not produce shippable binaries. The goal of the notebook is to produce code that goes *inside* an app's data and model layers, prototyped before the project exists.

**Does this work with Swift Playgrounds?** Quiver Notebook is a separate tool. Overall, Playgrounds and the notebook serve different audiences and are not interoperable. A snippet from one can be copied to the other if it only uses Foundation and standard library types, but Quiver and Structures are not available inside Swift Playgrounds.

**Where is the debugger?** There is no step debugger or breakpoint UI in the notebook. The intended workflow is the print-and-inspect loop — write a snippet, click Run, read the output, edit, run again. For real debugging needs (breakpoints, variable inspection, call stack), Xcode is the right tool, and snippets transfer there cleanly.

**Can I save my work?** The editor auto-saves to the browser's local storage, so refreshing the page does not lose code. For longer-term storage, copy the snippet into an `examples/` file or into a separate notes file — local storage is convenient but not durable across browser profiles or machine moves.

**Does the notebook work offline?** Yes, after the first build. The first `swift run` fetches Quiver, Structures, and the Vapor framework from their package repositories; subsequent runs are entirely local. A class running in an air-gapped lab can clone-and-build once on a connected machine, then distribute.

**What is the network and storage footprint?** The Vapor server listens only on `127.0.0.1:8080` (or the port set by `PORT=`) and accepts connections only from the same machine. No outbound calls are made once the initial `swift package` fetch is complete. Code typed in the editor is held in the browser's local storage and is scoped to that browser profile on that machine — closing the tab keeps it, switching browsers does not. CSVs dropped into `user/` are read from disk by the local process and never transmitted.

**Will my code or data leave the machine?** No. There are no accounts, no telemetry, and no analytics.

**Can multiple students share one notebook server?** No, by design. Quiver Notebook executes Swift with the permissions of the user who launched it, which is the right model for one person on one laptop. Each student runs their own copy. A shared-server deployment would need sandboxing, resource limits, and per-user isolation that the v0 scope does not include.

**How does this compare to Google Colab or Jupyter notebooks?** Colab is hosted in the cloud and good when we want a workspace in the browser without installing anything. Jupyter is the older browser-based notebook, runs locally or hosted, and is built around cells and kernels.

Quiver Notebook is the Swift counterpart for this kind of work — a local environment that lives on the same machine as the Apple-platform project it feeds. Each snippet is a whole Swift program that compiles and runs end-to-end, which fits how Swift code is actually shipped.

## Troubleshooting

* **Port 8080 is already in use** — launch on a different port: `PORT=8090 swift run`
* **Status chip reads "Warming up"** — normal on first run; the build typically takes one to two minutes
* **Status chip reads "Warm-up failed"** — the first run will still work and trigger the build then; check the terminal for the compiler error
* **The Run button does nothing** — open the browser console and check for fetch errors against `/api/run`; restart `swift run` if the Vapor server crashed
* **Examples sidebar is empty** — drop one `.swift` file with a `// Title:` comment on the first line into `examples/` and refresh

## Stay in the loop

[The Feature Vector](https://featurevector.substack.com) is a newsletter about ML intuition for engineers, built in Swift. One idea per issue, with a recipe that runs in the notebook.

## Documentation

Full Quiver API documentation at [waynewbishop.github.io/quiver](https://waynewbishop.github.io/quiver/documentation/quiver/). The Structures package is used throughout [Swift Algorithms & Data Structures](https://waynewbishop.github.io/swift-algorithms/), and the [Quiver Cookbook](https://github.com/waynewbishop/quiver-cookbook) collects 44 interactive recipes that run as-is in the notebook.

## Contributing, license, questions

Contributions are welcome — pull requests for `examples/` are especially welcome. Quiver Notebook is available under the MIT License. For other questions, reach out on [LinkedIn](https://www.linkedin.com/in/waynebishop).
