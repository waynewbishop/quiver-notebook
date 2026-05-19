# The Quiver Notebook

A browser-based Swift editor for exploring vectors, matrices, statistics, and machine learning with Quiver.

## Overview

The Quiver Notebook provides a fast, lightweight environment for learning [Quiver](https://waynewbishop.github.io/quiver/documentation/quiver/) and for prototyping. Established as a standalone web-based IDE, it serves two audiences: students who want to learn statistics, linear algebra, and machine learning in Swift, and developers who want a quick iteration loop for testing and building their own models.

To start, clone the repository and a browser opens with `Quiver`, `Foundation`, and a small library of teaching datasets ready to use. Once the Swift toolchain is installed, no additional binaries are required.

## Who the Notebook is for

- **iOS and Apple-platform developers** — get a focused editor for prototyping a model or testing an idea. Code that runs here compiles unchanged on any Apple platform, including iOS, watchOS, visionOS, and Vapor server-side targets.
- **Students** — get a Swift environment that does numerical work without installing additional binaries or downloading datasets separately. One clone and one command produce a working editor with `Quiver`, `Foundation`, and the bundled datasets already wired in.
- **Educators** — fork the repository, drop custom examples into the `examples-custom/` folder, and share the URL with a class. The bundled stack covers an applied linear algebra unit, an introductory descriptive statistics segment, an applied regression module, and a short supervised learning survey using k-nearest neighbors, k-means, and Naive Bayes.

The Notebook itself runs from the Swift command-line toolchain, so Xcode is not required to use it. Any code written in the editor compiles unchanged inside an Xcode project that depends on Quiver, so a model prototyped here ships in an iOS, watchOS, visionOS, or Vapor app without translation.

## Quick Start

The Quiver Notebook runs on macOS 15 (Sequoia) or newer with Swift 6.0 or newer.

### About Homebrew

Homebrew is the standard package manager for macOS — a free tool that installs developer software from a single command line. The Quiver Notebook docs recommend Homebrew because it handles three things at once: it downloads the Swift toolchain installer, keeps it updated alongside other developer tools, and makes the whole install reproducible across student machines. Anything Homebrew installs can also be uninstalled cleanly with a single command.

If a Mac already has Homebrew, skip to step 2.

### 1. Install Homebrew

Open the **Terminal** application (in Applications → Utilities, or search "Terminal" in Spotlight). Paste this command and press Return — it downloads and runs the official Homebrew install script from [brew.sh](https://brew.sh):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

On a fresh Mac, the installer prompts for Apple's Command Line Tools first and pauses while they download — this is a one-time Apple step that Homebrew depends on, not a hang. Approve the prompt and the Homebrew install continues automatically when the Command Line Tools finish.

The install takes a few minutes and may ask for the Mac's password. That's expected — Homebrew installs system-wide.

When the install finishes, confirm Homebrew is working by checking its version:

```bash
brew --version
```

The terminal should print a line like `Homebrew 4.4.0`. If it says "command not found," the install didn't add Homebrew to the terminal's search path — close the terminal window, open a new one, and try again.

### 2. Install Swiftly through Homebrew

**Swiftly** is Swift's official toolchain installer, maintained by the Swift project itself. We use Homebrew from step 1 to install Swiftly, and Swiftly installs the actual Swift compiler.

Install Swiftly:

```bash
brew install swiftly
```

Confirm Homebrew is managing the install:

```bash
brew list swiftly
```

This prints the list of files Homebrew installed for the Swiftly package. A successful install shows several file paths. An empty result or an error means the install didn't complete.

### 3. Install the Swift toolchain

With swiftly installed, run it once to download and configure the Swift compiler itself:

```bash
swiftly init
```

The download takes a few minutes. When it finishes, confirm Swift is available:

```bash
swift --version
```

The terminal should print a Swift version line that begins with `Swift version 6.` followed by a minor and patch number. If it says "command not found," close the terminal window and open a new one — the install only takes effect in new terminal sessions.

### 4. Clone and run the Notebook

The Notebook lives in its own GitHub repository. Clone a copy to the Mac and start it:

```bash
git clone https://github.com/waynewbishop/quiver-notebook
cd quiver-notebook
swift run
```

The first launch takes a minute or two while Swift compiles the Notebook and pre-warms the snippet sandbox. The sandbox is a separate Swift package that depends on Quiver, so the first launch downloads and compiles Quiver from GitHub. Subsequent runs use the cached build and start in seconds. When the server is ready, the terminal prints a banner:

```
==========================================================
  Quiver Notebook is running.

  Open this URL in your browser:
  http://localhost:8080

  If port 8080 is in use, restart with: PORT=8090 swift run
==========================================================
```

Open the URL in any browser to start writing snippets. Press `Ctrl+C` in the terminal to stop the server.

The local server binds to `127.0.0.1` by design and refuses to start if the address is changed. The Notebook is reachable only from the same machine that launched it.

## Bundled datasets

The Quiver Notebook ships with a small library of teaching datasets accessible by name from the editor — no download, no parsing, no setup. Iris, Titanic, California Housing, and a handful of others are ready to load with a single line of code, paired with sensible target columns for either classification or regression. A separate loader reads any CSV from disk in the same shape, so a class can move from bundled data to its own data without changing the rest of a snippet.

The full menu of datasets, the loading API, and the categorical-encoding behavior are documented at [Notebook Datasets](https://waynewbishop.github.io/quiver/documentation/quiver/notebook-datasets).

## Bundled examples

The left sidebar of the editor lists ready-to-run snippets, ordered from simplest to most complex. Each example loads into the editor with one click. The Notebook reads two folders: `examples/` for the bundled snippets shipped with the repository, and `examples-custom/` for files added by an instructor. Drop new `.swift` files into `examples-custom/` — there is no plugin system, no manifest, and no rebuild required. Restart `swift run` to pick up newly added files. Custom entries appear in the sidebar after the bundled set.

Each example file begins with a `// Title:` comment on the first line, and the text after the colon becomes the sidebar label.

## Documentation

The Notebook's full reference documentation lives in the Quiver DocC catalog:

- [Quiver Notebook](https://waynewbishop.github.io/quiver/documentation/quiver/quiver-notebook) — overview, setup, snippet rules, app handoff
- [Notebook Datasets](https://waynewbishop.github.io/quiver/documentation/quiver/notebook-datasets) — the bundled dataset library and CSV loader
- [Quiver Notebook for Classrooms](https://waynewbishop.github.io/quiver/documentation/quiver/quiver-notebook-for-classrooms) — fork-and-distribute model, custom examples, version pinning, port configuration

For the Quiver package itself, see the full [Quiver documentation](https://waynewbishop.github.io/quiver/documentation/quiver/) and the [Quiver Cookbook](https://github.com/waynewbishop/quiver-cookbook) for interactive recipes.

## Contributing

Pull requests for `examples/` are especially welcome. For other contributions or questions, open an issue or reach out on [LinkedIn](https://www.linkedin.com/in/waynebishop).

## License

MIT.
