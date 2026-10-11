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

Custom examples are listed after the bundled examples and appear
in the sidebar with the title from their `// Title:` comment, the
same as bundled examples.

Files are read fresh each time the page loads. Refresh the
browser to pick up newly added files; there is no need to restart
`swift run`.

Files dropped here can be committed to a fork so that students or
collaborators who clone the fork see the same custom examples.
This folder's `.swift` files are git-ignored so personal scratch
files stay out of commits, so add them with the `-f` flag:

```bash
git add -f examples-custom/*.swift
```

Files in the bundled `examples/` folder come from the upstream
repository; this folder is the place to add course-specific or
project-specific snippets without conflicting with upstream updates.
