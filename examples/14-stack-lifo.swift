// Title: A Stack in Swift
//
// A stack is last-in-first-out (LIFO): the most recently pushed value is
// the first one popped. Stacks model anything where the order of work
// reverses the order of arrival — undo histories, function call frames,
// matched-bracket checking, depth-first search.
//
// Structures' Stack<T> is generic and conforms to Sequence. The core API
// is push, pop, peek, and isEmpty. popValue returns the removed element;
// pop discards it.

let history = Stack<String>()

history.push("opened editor")
history.push("typed import Quiver")
history.push("ran the cell")

print("most recent action:", history.peek() ?? "—")

// Pop one action — undo.
let undone = history.popValue()
print("undid:", undone ?? "—")

print()
print("remaining history (top first):")
for action in history {
    print("  ·", action)
}

// Common stack use: balanced-bracket check.
func bracketsBalanced(_ source: String) -> Bool {
    let pairs: [Character: Character] = [")": "(", "]": "[", "}": "{"]
    let openers: Set<Character> = ["(", "[", "{"]
    let pending = Stack<Character>()

    for character in source {
        if openers.contains(character) {
            pending.push(character)
        } else if let expected = pairs[character] {
            if pending.popValue() != expected { return false }
        }
    }
    return pending.isEmpty()
}

print()
print("balanced '([]{})':", bracketsBalanced("([]{})"))
print("balanced '([)]':", bracketsBalanced("([)]"))
