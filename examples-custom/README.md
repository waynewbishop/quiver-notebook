# Custom Examples

Drop `.swift` files into this folder and they will appear in the
Quiver Notebook examples panel alongside the bundled examples.

Each file should start with a title comment so the Notebook knows
how to label it in the list:

```swift
// Title: My Lesson on Vectors

let xs = [1.0, 2.0, 3.0]
print(xs.reduce(0, +))
```

Custom examples are listed after the bundled examples and have
their title prefixed with `Custom — ` so it's clear which folder
they came from.

Files are read fresh each time the Notebook starts. Restart
`swift run` to pick up newly added files.

This folder is ignored by Git (other than this README), so files
you drop here stay on your machine and never get committed.
