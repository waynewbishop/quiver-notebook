# The Quiver Notebook

A browser-based Swift editor for exploring vectors, matrices, statistics, and machine learning with Quiver.

## Overview

The Quiver Notebook provides a fast, lightweight environment for learning [Quiver](https://waynewbishop.github.io/quiver/documentation/quiver/) and for prototyping. Established as a standalone web-based IDE, it serves two audiences: students who want to learn statistics, linear algebra, and machine learning in Swift, and developers who want a quick iteration loop for testing and building their own models.

To start, clone the repository and a browser opens with `Quiver`, `Foundation`, and a small library of teaching datasets ready to use. Nothing else needs to be installed beyond the Swift CLI.

## Who the Notebook is for

- **iOS and Apple-platform developers** — get a focused editor for prototyping a model or testing an idea. Code that runs here compiles unchanged on any Apple platform, including iOS, watchOS, visionOS, and Vapor server-side targets.
- **Students** — get a Swift environment that does numerical work without installing additional binaries or downloading datasets separately. One clone and one command produce a working editor with `Quiver`, `Foundation`, and the bundled datasets already wired in.
- **Educators** — fork the repository, drop custom examples into the `examples/` folder, and share the URL with a class. The bundled stack covers an applied linear algebra unit, an introductory descriptive statistics segment, an applied regression module, and a short supervised learning survey using k-nearest neighbors, k-means, and Naive Bayes.

The Notebook itself runs from the Swift command-line toolchain, so Xcode is not required to use it. Any code written in the editor compiles unchanged inside an Xcode project that depends on Quiver, so a model prototyped here ships in an iOS, watchOS, visionOS, or Vapor app without translation.

## Quick Start

The Notebook runs on the Swift command-line toolchain. The lightest way to get Swift on macOS is **swiftly**, Swift's official toolchain installer. It runs as a normal Mac installer and does not require Homebrew or Xcode. For a smooth install we recommend having macOS 15 (Sequoia) or newer.

1. Download the installer: [swiftly-1.1.1.pkg](https://download.swift.org/swiftly/darwin/swiftly-1.1.1.pkg)
2. Double-click the downloaded file and follow the prompts.
3. Open a new terminal tab and run:

   ```bash
   ~/.swiftly/bin/swiftly init
   ```

   This downloads the latest Swift toolchain into your home folder and configures your shell.
4. Confirm the install:

   ```bash
   swift --version
   ```

Once Swift is in place, clone and run:

```bash
git clone https://github.com/waynewbishop/quiver-notebook
cd quiver-notebook
swift run
```

Then open `http://localhost:8080` in a browser. The first launch compiles the libraries and the editor, which takes a minute or two on most machines. Every launch after that starts in seconds.

The local server binds to `127.0.0.1` by design and refuses to start if the address is changed. The Notebook is reachable only from the same machine that launched it.

## Bundled datasets

The Quiver Notebook ships with a small library of teaching datasets accessible by name from the editor — no download, no parsing, no setup. Iris, Titanic, California Housing, and a handful of others are ready to load with a single line of code, paired with sensible target columns for either classification or regression. A separate loader reads any CSV from disk in the same shape, so a class can move from bundled data to its own data without changing the rest of a snippet.

The full menu of datasets, the loading API, and the categorical-encoding behavior are documented at [Notebook Datasets](https://waynewbishop.github.io/quiver/documentation/quiver/notebook-datasets).

## Bundled examples

The left sidebar of the editor lists ready-to-run snippets, ordered from simplest to most complex. Each example loads into the editor with one click. Educators extend the sidebar by dropping their own `.swift` files into the `examples/` folder — there is no plugin system, no manifest, and no rebuild required. Refresh the browser tab and the new entries appear.

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
