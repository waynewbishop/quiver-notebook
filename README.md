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
* **The two-package stack** — Quiver and Structures together cover a full college ML course in Swift. Add `import Structures` when you need data structures and algorithms; `import Quiver` is wired in by default

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
  * `Quiver` — vectors, matrices, statistics, ML models (Linear Regression, K-Means, Naive Bayes, K-Nearest Neighbors). Auto-imported.
  * `Structures` — data structures and algorithms from *Swift Algorithms & Data Structures*: heaps, tries, graphs, stacks, queues, binary search trees. Add `import Structures` when you need it.
  * `Foundation` — Date, JSON, file reading, strings, regular expressions. Auto-imported.
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
* **Two-package discipline** — Quiver and Structures are enough for a college ML course. More libraries would dilute the focus
* **Transparent** — students read the source of everything they use, including this notebook itself
* **Educational** — the tool is built to be inspected, modified, and taught from

## When to Use Quiver Notebook

* **Teaching a Swift-based ML course** — a pure-Swift classroom environment that runs on every student's machine
* **Running exercises in restricted networks** — air-gapped labs, K-12 classrooms, exam environments
* **Student self-study** — anyone reading *Swift Algorithms & Data Structures* who wants to experiment alongside the book
* **Prototyping ML for Apple devices** — sketch a model in pure Swift before dropping it into an iOS, watchOS, or visionOS app, without creating an Xcode project
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

Quiver Notebook is a local-first tool. It runs on the same computer the student or instructor is sitting at, with the same Swift toolchain a working developer uses. Code is written in the browser, executed by a small Vapor server on the same machine, and the output comes back to the same browser tab. Nothing leaves the computer.

### Who it's for

* **Students** working through a course, a textbook, or self-study — they clone the repo to their own laptop and write code in their own browser
* **Educators** preparing lectures or assignments — they fork the repo, drop their own examples into the `examples/` folder, and hand the fork URL to the class
* **Developers** building ML models for Apple devices — a lightweight, focused environment for prototyping a model in pure Swift before dropping it into an iOS, watchOS, or visionOS app

Each person runs their own copy. That is the design.

### What's protected by default

* **Localhost-only** — the server binds to `127.0.0.1`, so only the computer running the notebook can reach it. Other machines on the same Wi-Fi cannot connect. The app refuses to start if the bind address is changed.
* **No accounts, no telemetry, no cloud** — student code, output, and errors stay on the student's machine. There is no analytics endpoint, no login, no crash reporter
* **Pinned Quiver version** — every student who clones the repo gets the same Quiver release, recorded in `sandbox/Package.resolved`. A course built in September still works in May

### What clone-and-run enables

* **No IT review** — nothing leaves the student's machine, so there is no data-handling policy to clear with a university privacy office
* **No vendor dependency** — there is no service that can change pricing, throttle a free tier, or shut down mid-semester
* **Works offline** — once the repo is cloned and the sandbox is built, no internet connection is needed
* **Free at any scale** — twenty students or two hundred students, the install path is the same `git clone`

### A note on shared hosting

Quiver Notebook executes Swift with the permissions of the user who launched it. That is the right model for one user on one laptop, which is why the default is localhost-only.

A shared server, a department-wide URL, or any deployment where multiple people connect to the same instance is a different problem — it needs sandboxing, resource limits, and isolation between users. The notebook is not designed for that use case. If you want to run Quiver in a hosted environment, reach out first and I can point you in the right direction.

## Troubleshooting

### Port 8080 is already in use

Something else on the machine — Docker, a Java app, another Vapor project — is bound to port 8080. The notebook's terminal log will show a `Could not bind to port 8080` error. Run on a different port instead:

```bash
PORT=8090 swift run
```

`PORT` accepts any value from 1 to 65535. The notebook logs which port it ended up using, so the URL to open in the browser will be in the startup output: `Server started on http://localhost:8090`.

### The status chip in the top bar reads "Warming up"

This is normal on the first run after cloning. The notebook compiles Quiver, Structures, and their dependencies into the sandbox so subsequent runs are fast — the build typically takes one to two minutes. The chip flips to "Ready" automatically when the warm-up completes. Code can be written and edited during warm-up; only Run is blocked until the sandbox is built.

If warm-up takes longer than six minutes the chip will read "Warming up (taking longer than usual)" — that is honest reporting rather than a failure. Slow networks fetching package dependencies are the usual cause; the build will continue and Run will work once it finishes.

### The status chip reads "Warm-up failed"

The first build did not complete cleanly. The first Run will still work; it will just trigger the build at that point instead of in the background. Check the terminal log for the underlying compiler error — the most common causes are an outdated Swift toolchain (the notebook needs Swift 5.9+) or an interrupted package fetch.

### The Run button does nothing

Open the browser console (Option-Cmd-J on macOS, Ctrl-Shift-J on Linux) and look for fetch errors against `/api/run`. If the request is returning a non-JSON response, the Vapor server probably crashed — check the terminal where `swift run` is running. Restart with `swift run` if needed.

### Examples sidebar is empty

The notebook discovers examples by scanning the `examples/` directory at startup. If the directory is empty or missing, the sidebar shows "No examples found." This is also what new educators see right after deleting the bundled examples to make room for their own — drop one `.swift` file with a `// Title:` comment on the first line and refresh the page.

## Documentation

* **Quiver** — full API documentation at [waynewbishop.github.io/quiver](https://waynewbishop.github.io/quiver/documentation/quiver/)
* **Structures** — used throughout [Swift Algorithms & Data Structures](https://waynewbishop.github.io/swift-algorithms/)
* **Cookbook** — 44 interactive Quiver recipes at [quiver-cookbook](https://github.com/waynewbishop/quiver-cookbook)

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
