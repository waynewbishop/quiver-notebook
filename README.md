# Quiver Notebook — A local Swift notebook for learning numerical computing and machine learning

Quiver Notebook is a browser-based Swift editor that runs on your own computer, with [Quiver](https://github.com/waynewbishop/quiver) and [Structures](https://github.com/waynewbishop/bishop-algorithms-swift-package) already imported.

* Runs locally on your Mac or Linux laptop — works offline
* Quiver and Structures pre-imported — just write Swift
* Your code never leaves your computer

## For educators

Quiver Notebook is designed for classroom use:

* **No institutional approval** — it runs on each student's machine, not a third-party service, so there is no security review to schedule
* **No vendor dependency** — once a student clones the repo, the tool is theirs. No service can change pricing, shut down a free tier, or revoke access mid-semester. A course built on Quiver Notebook in September still works in May
* **Works offline** — once cloned, no internet connection is needed to write or run code
* **Forkable curriculum** — drop your own `.swift` files into the `examples/` folder and they appear in the sidebar
* **Free to distribute at any scale** — students clone the repo themselves, so there is no per-seat cost
* **The two-package stack** — Quiver and Structures cover a full college ML course in Swift, as an alternative to Python + NumPy

### Adding your own examples

Any `.swift` file in the `examples/` directory appears in the sidebar. Add a title comment on the first line:

```swift
// Title: Your Example Title
//
// Short description of what this example shows.

let values = [1.0, 2.0, 3.0]
print(values.mean() ?? 0)
```

Filenames are listed alphabetically, so prefix with `01-`, `02-`, etc. to order them by lecture or topic.

## Quick Start

```bash
git clone https://github.com/waynewbishop/quiver-notebook
cd quiver-notebook
swift run
```

Then open [http://localhost:8080](http://localhost:8080) in your browser.

The first launch compiles Quiver and Structures and caches them — this takes a minute or two. Subsequent runs are fast.

## Features

* **Browser-based Swift editor**
  * Monaco editor (the editor from VS Code) with Swift syntax highlighting
  * Cmd/Ctrl + Enter to run
  * Auto-save to the browser's local storage — student work persists across refreshes
  * Copy-to-clipboard for sharing code in assignments and messages

* **One-click run loop**
  * Write Swift, press Run, see output
  * Errors reported inline with line numbers
  * Execution time shown for performance discussions

* **Pre-wired two-package stack**
  * `Quiver` — vectors, matrices, statistics, ML models (Linear Regression, K-Means, Naive Bayes, K-Nearest Neighbors)
  * `Structures` — data structures and algorithms from *Swift Algorithms & Data Structures*: heaps, tries, graphs, stacks, queues, binary search trees
  * `Foundation` — Date, JSON, file reading, strings, regular expressions
  * No other libraries — the whole ML course fits in these three

* **Curated examples sidebar**
  * Ready-to-run snippets covering mean and standard deviation, cosine similarity, linear regression, softmax, and k-means clustering
  * Each example loads into the editor with one click
  * Educators extend the sidebar by adding their own `.swift` files

* **Local-first and private**
  * Runs on `127.0.0.1` (localhost only)
  * Student code never leaves the machine
  * No telemetry, no analytics, no account system
  * The footer shows the Quiver version currently running, read directly from the resolved package

## Your First Example

```swift
let values = [2.0, 4.0, 6.0, 8.0, 10.0]
print("mean:", values.mean() ?? 0)
```

Click Run. The output pane shows `mean: 6.0`. No `import Quiver` needed — the notebook injects it automatically. Edit the array, click Run again, watch the answer change.

## Example: Train a Model in the Notebook

```swift
// Training data: square footage → price
let features: [[Double]] = [[1000], [1500], [2000], [2500], [3000]]
let targets = [150000.0, 200000.0, 260000.0, 310000.0, 370000.0]

let model = try LinearRegression.fit(features: features, targets: targets)
let predictions = model.predict(features)
let r2 = predictions.rSquared(actual: targets)

print("predictions:", predictions)
print("R²:", r2)
```

## Example: Cluster with K-Means

```swift
let points: [[Double]] = [
    [1.0, 1.0], [1.2, 1.1], [0.9, 1.3],
    [5.0, 5.0], [5.2, 4.9], [4.8, 5.1],
    [9.0, 1.0], [9.1, 0.8], [8.9, 1.2]
]

let model = KMeans.fit(data: points, k: 3)
print("cluster labels:", model.predict(points))
```

## Design Philosophy

* **Local-first** — runs entirely on the student's machine, never phones home
* **Frictionless** — clone, `swift run`, write code. No accounts, no setup rituals
* **Two-package discipline** — Quiver and Structures are enough for a college ML course. More libraries would dilute the pedagogical story
* **Transparent** — students read the source of everything they use, including this notebook itself
* **Educational** — the tool is built to be inspected, modified, and taught from

## When to Use Quiver Notebook

* **Teaching a Swift-based ML course** — replace Python + Jupyter with a pure-Swift classroom environment
* **Running exercises in restricted networks** — air-gapped labs, K-12 classrooms, exam environments
* **Student self-study** — anyone reading *Swift Algorithms & Data Structures* who wants to experiment alongside the book
* **Rapid prototyping** — quick Swift + Quiver experiments without creating an Xcode project
* **Workshops and tutorials** — a shared environment attendees install in under a minute

## What's in this Repository

```
quiver-notebook/
├── Package.swift           # Vapor app dependencies
├── Sources/App/            # Routes, code runner, examples loader
├── Resources/Views/        # Leaf template for the editor page
├── Public/                 # CSS, JavaScript, Monaco loader
├── examples/               # Sample .swift snippets shown in the sidebar
├── sandbox/                # Separate Swift package with Quiver + Structures
└── README.md
```

## How it Works

1. The Vapor app serves a browser-based Swift editor at `http://localhost:8080`
2. When a student clicks Run, their code is written into the sandbox package
3. The sandbox compiles and runs the code with `swift run`, which has Quiver and Structures pre-linked
4. Output streams back into the browser output pane

The student's code never leaves the computer.

## Requirements

* macOS 13+ or Linux with Swift 5.9+
* Swift toolchain (bundled with Xcode on macOS, or install from [swift.org](https://www.swift.org/download/))

## Keeping Quiver Current

The notebook ships with a specific version of Quiver pinned in `sandbox/Package.resolved`, so every student who clones the repo gets the same known-good version. The footer shows which version is running.

When a new Quiver release is available and you would like to use it, run this once inside the `sandbox/` directory:

```bash
cd sandbox
swift package update
```

The next `swift run` rebuilds against the new version, and the footer updates automatically. A course built on a pinned version keeps working as long as the repo is checked out — there is no forced upgrade.

## Running the Notebook Safely

Quiver Notebook is built to run on your own computer, one user per instance. The defaults keep it that way:

* **Localhost-only by default** — the server binds to `127.0.0.1`, so only the computer running the notebook can reach it. The app refuses to start if this is changed.
* **No accounts, no telemetry, no cloud** — student code stays on the student's machine.
* **Clone-and-run for classrooms** — each student runs their own copy. That is the intended deployment, and it works anywhere Swift runs.

A note for anyone thinking about shared hosting: like any tool that runs code you write (Xcode, a REPL, a Python notebook), the notebook executes Swift with the permissions of the user who launched it. That is fine for a single-user laptop, and it is why the notebook is localhost-only. If you ever want to put it on a shared server or expose the port externally, reach out first — that is a different deployment model and a hosted Swift service is usually the better fit.

## Documentation

* **Quiver** — full API documentation at [waynewbishop.github.io/quiver](https://waynewbishop.github.io/quiver/documentation/quiver/)
* **Structures** — used throughout [Swift Algorithms & Data Structures](https://waynewbishop.github.io/swift-algorithms/)
* **Cookbook** — 38 interactive Quiver recipes at [quiver-cookbook](https://github.com/waynewbishop/quiver-cookbook)

## Status

Version 0 — the minimum viable notebook. Free-form Swift execution with Quiver + Structures, examples sidebar, auto-save, copy-to-clipboard, localhost-only execution.

Planned: Xcode-inspired editor theme, Quiver brand styling pass, shareable URLs, cell-based interface.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Educator-contributed example files in `examples/` are especially welcome.

## License

Quiver Notebook is available under the MIT License. See the LICENSE file for more info.

## Newsletter

[The Feature Vector](https://featurevector.substack.com) — a newsletter about ML intuition for engineers, built in Swift. One idea per issue, with a recipe you can run in the notebook.

## Questions

Have a question? Feel free to contact me on [LinkedIn](https://www.linkedin.com/in/waynebishop).
