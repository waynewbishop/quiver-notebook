#!/usr/bin/env swift
// generate-sandbox-docs.swift
// Extract Dataset/DatasetLoader symbol names, signatures, and doc summaries
// from the sandbox's Datasets/*.swift sources and merge them into the
// existing Public/quiver-docs.json file used by the Monaco hover provider.
//
// Why a hand-rolled extractor instead of `swift package dump-symbol-graph`:
// the sandbox's `Runner` is an executableTarget. SwiftPM's symbol-graph
// dump skips executable targets, so it emits nothing for `Runner`. Rather
// than reorganize the sandbox into a library just to get hover docs, we
// parse the three small files in Datasets/ directly.
//
// The parser tracks brace nesting so it only captures declarations that
// live at type or extension scope (depth 0 or 1) — function-body locals
// (`let url = ...`, etc.) are skipped. Each captured declaration takes its
// preceding contiguous `///` block as the doc summary (first paragraph
// only, matching the rule used by Scripts/generate-docs.swift for Quiver).
//
// Merge policy: existing keys in quiver-docs.json win unless this script's
// entry has a non-empty summary AND either the existing entry has no
// summary or the symbol is on the explicit Dataset surface listed in
// `expectedKeys`. This protects Quiver's `init` (Fraction.init) while
// still letting `description`/`name` flip to the Dataset variant — those
// were called out in the spec as the entries the Notebook hover should
// expose.
//
// Usage: swift Scripts/generate-sandbox-docs.swift
//
// Reads:  /Users/waynebishop/Projects/quiver-notebook/sandbox/Sources/Runner/Datasets/*.swift
// Writes: /Users/waynebishop/Projects/quiver-notebook/Public/quiver-docs.json
//         (preserving every Quiver entry that was already in the file
//         except where this script intentionally overrides it.)

import Foundation

let datasetsDir = "/Users/waynebishop/Projects/quiver-notebook/sandbox/Sources/Runner/Datasets"
let outputPath = "/Users/waynebishop/Projects/quiver-notebook/Public/quiver-docs.json"

let sources = [
    "DatasetType.swift",
    "Dataset+Bundled.swift",
    "DatasetLoader.swift"
]

// Symbols we want the Notebook hover to surface, in priority order. Any
// captured symbol whose name is in this set wins over the existing JSON
// entry; symbols outside this set only fill empty slots.
let expectedKeys: Set<String> = [
    "Dataset",
    "DatasetLoader",
    "iris",
    "titanic",
    "californiaHousing",
    "bikeSharing",
    "studentPerformance",
    "glove50d",
    "load",
    "catalog",
    "toPanel",
    "categoricalMappings",
    "name",
    "description"
]

struct Entry {
    let signature: String
    let summary: String?
}

// MARK: - Parser

/// Strips // and /* comments from a line, returning the cleaned text. Used
/// only for brace counting so trailing `//` comments don't fool the depth
/// tracker.
func stripComments(_ line: String) -> String {
    var result = ""
    var i = line.startIndex
    var inString = false
    while i < line.endIndex {
        let c = line[i]
        if c == "\"" { inString.toggle() }
        if !inString {
            if c == "/", line.index(after: i) < line.endIndex, line[line.index(after: i)] == "/" {
                break
            }
        }
        result.append(c)
        i = line.index(after: i)
    }
    return result
}

/// Counts the net change in brace depth on a line (open minus close),
/// ignoring braces that appear inside string literals.
func braceDelta(_ line: String) -> Int {
    var delta = 0
    var inString = false
    for c in stripComments(line) {
        if c == "\"" { inString.toggle(); continue }
        if inString { continue }
        if c == "{" { delta += 1 }
        else if c == "}" { delta -= 1 }
    }
    return delta
}

/// Returns the symbol name extracted from a Swift declaration line, or nil
/// if the line doesn't introduce a symbol we want to index.
func extractSymbolName(from declaration: String) -> String? {
    let trimmed = declaration.trimmingCharacters(in: .whitespaces)

    // Strip access-control / qualifier prefixes so we can read keyword + name.
    let prefixesToStrip = ["public ", "internal ", "private ", "fileprivate ",
                           "open ", "static ", "final ", "override ",
                           "@inlinable ", "@inline(__always) ",
                           "@discardableResult "]
    var working = trimmed
    var changed = true
    while changed {
        changed = false
        for prefix in prefixesToStrip {
            if working.hasPrefix(prefix) {
                working.removeFirst(prefix.count)
                working = working.trimmingCharacters(in: .whitespaces)
                changed = true
            }
        }
    }

    if working.hasPrefix("init") || working.hasPrefix("init(") {
        return "init"
    }

    let keywords = ["func", "var", "let", "struct", "enum", "class", "extension"]
    for keyword in keywords {
        let prefix = keyword + " "
        if working.hasPrefix(prefix) {
            // We don't index extension blocks themselves — we want the type.
            if keyword == "extension" { return nil }

            let rest = String(working.dropFirst(prefix.count))
                .trimmingCharacters(in: .whitespaces)
            var name = ""
            for ch in rest {
                if "(:<= {".contains(ch) { break }
                name.append(ch)
            }
            return name.isEmpty ? nil : name
        }
    }
    return nil
}

/// Strips a trailing `{` so the recorded signature is one clean line.
func cleanSignature(_ raw: String) -> String {
    var s = raw.trimmingCharacters(in: .whitespaces)
    if s.hasSuffix("{") {
        s.removeLast()
        s = s.trimmingCharacters(in: .whitespaces)
    }
    return s
}

/// Parses a single Swift source file into (symbolName, Entry) pairs at
/// type/extension scope. Brace depth is tracked across the whole file so
/// declarations inside function bodies (depth >= 2 typically) are skipped.
func parse(_ source: String) -> [(String, Entry)] {
    let lines = source.components(separatedBy: "\n")
    var results: [(String, Entry)] = []
    var pendingDoc: [String] = []
    var depth = 0
    var i = 0

    while i < lines.count {
        let raw = lines[i]
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        let depthAtLineStart = depth

        if trimmed.hasPrefix("///") {
            var text = String(trimmed.dropFirst(3))
            if text.hasPrefix(" ") { text.removeFirst() }
            pendingDoc.append(text)
            depth += braceDelta(raw)
            i += 1
            continue
        }

        if trimmed.isEmpty || trimmed.hasPrefix("//") || trimmed.hasPrefix("/*") {
            pendingDoc = []
            depth += braceDelta(raw)
            i += 1
            continue
        }

        // Only top-of-type declarations count. depthAtLineStart 0 = top of
        // file (struct/enum/extension), 1 = inside a type/extension body
        // (members). depth >= 2 = inside a function body or nested closure.
        let canIndex = depthAtLineStart <= 1

        // Some declarations span multiple lines (e.g. an `internal init(`
        // whose parameter list breaks across lines). Glue lines together
        // until we hit the opening brace of the body, the end of an
        // expression-bodied declaration, or another declaration line.
        var declaration = trimmed
        var consumed = 1
        if canIndex,
           !declaration.contains("{"),
           !declaration.hasSuffix(",") {
            var look = i + 1
            while look < lines.count {
                let next = lines[look].trimmingCharacters(in: .whitespaces)
                if next.isEmpty { break }
                if next.hasPrefix("///") || next.hasPrefix("//") { break }
                declaration += " " + next
                consumed += 1
                if next.contains("{") { break }
                if next.hasSuffix(")") || next.hasSuffix("]") || next.hasSuffix("?")
                    || next.contains("->") {
                    // Likely the tail of a func signature or a typed property.
                    break
                }
                look += 1
            }
        }

        if canIndex, let name = extractSymbolName(from: declaration) {
            // First paragraph only — `///` blank lines (rendered as empty
            // strings in pendingDoc) terminate the summary.
            var firstParagraph: [String] = []
            for line in pendingDoc {
                if line.trimmingCharacters(in: .whitespaces).isEmpty { break }
                firstParagraph.append(line)
            }
            let summary = firstParagraph.isEmpty
                ? nil
                : firstParagraph.joined(separator: " ")
                    .trimmingCharacters(in: .whitespaces)

            // Skip the internal `init(name:description:...)` — its key would
            // collide with Fraction.init in quiver-docs.json and there's no
            // user-facing reason to surface it.
            if name == "init" {
                pendingDoc = []
            } else {
                let signature = cleanSignature(declaration)
                results.append((name, Entry(signature: signature, summary: summary)))
                pendingDoc = []
            }
        } else {
            pendingDoc = []
        }

        // Advance depth for every line we consumed in the multi-line glue.
        for k in 0..<consumed {
            depth += braceDelta(lines[i + k])
        }
        i += consumed
    }
    return results
}

// MARK: - Run

var newEntries: [String: Entry] = [:]

for filename in sources {
    let path = "\(datasetsDir)/\(filename)"
    guard let source = try? String(contentsOfFile: path, encoding: .utf8) else {
        FileHandle.standardError.write("Could not read \(path)\n".data(using: .utf8)!)
        exit(1)
    }
    let parsed = parse(source)
    for (name, entry) in parsed {
        if let existing = newEntries[name],
           (existing.summary?.count ?? 0) >= (entry.summary?.count ?? 0) {
            continue
        }
        newEntries[name] = entry
    }
    print("Parsed \(parsed.count) symbols from \(filename)")
}

// Verify every expected key was actually captured.
var missing: [String] = []
for key in expectedKeys where newEntries[key] == nil {
    missing.append(key)
}
if !missing.isEmpty {
    FileHandle.standardError.write(
        "Parser missed expected symbols: \(missing.sorted().joined(separator: ", "))\n"
            .data(using: .utf8)!
    )
    exit(1)
}

// Load existing quiver-docs.json and merge.
guard let existingData = try? Data(contentsOf: URL(fileURLWithPath: outputPath)),
      let existingMap = try? JSONSerialization.jsonObject(with: existingData)
        as? [String: [String: Any]]
else {
    FileHandle.standardError.write(
        "Could not read existing \(outputPath)\n".data(using: .utf8)!
    )
    exit(1)
}

var merged = existingMap
var added = 0
var overrode = 0
var skipped = 0

for (name, entry) in newEntries {
    var dict: [String: Any] = ["signature": entry.signature]
    if let summary = entry.summary {
        dict["summary"] = summary
    } else {
        dict["summary"] = NSNull()
    }

    if let existing = merged[name] {
        let existingSummary = existing["summary"] as? String
        let existingHasSummary = (existingSummary?.isEmpty == false)
        if expectedKeys.contains(name) {
            // Always take ours for the called-out Dataset surface.
            merged[name] = dict
            overrode += 1
        } else if !existingHasSummary, entry.summary != nil {
            // Fill in an empty Quiver slot (rare).
            merged[name] = dict
            overrode += 1
        } else {
            skipped += 1
        }
    } else {
        merged[name] = dict
        added += 1
    }
}

let outData = try JSONSerialization.data(
    withJSONObject: merged,
    options: [.prettyPrinted, .sortedKeys]
)
try outData.write(to: URL(fileURLWithPath: outputPath))

print("Added \(added) new sandbox entries; overrode \(overrode); skipped \(skipped) (Quiver wins)")
print("Total entries in \(outputPath): \(merged.count)")
print("File size: \(outData.count) bytes")
