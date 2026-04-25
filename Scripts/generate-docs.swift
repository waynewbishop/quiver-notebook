#!/usr/bin/env swift
// generate-docs.swift
// Extract Quiver symbol names, signatures, and doc summaries from the
// Swift toolchain's symbol-graph output and write a flat JSON map used by
// the Monaco hover provider in Public/js/app.js.
//
// Usage: swift Scripts/generate-docs.swift
//
// Source of truth is Wayne's local Quiver checkout. The script does not
// modify Quiver — it only reads the symbol graph the build system emits.

import Foundation

let quiverPath = "/Users/waynebishop/Projects/quiver"
let outputPath = "/Users/waynebishop/Projects/quiver-notebook/Public/quiver-docs.json"

// 1. Ask SwiftPM to emit the symbol graph. Writes JSON into .build/.../symbolgraph/.
let dump = Process()
dump.currentDirectoryURL = URL(fileURLWithPath: quiverPath)
dump.launchPath = "/usr/bin/env"
dump.arguments = ["swift", "package", "dump-symbol-graph"]
dump.standardOutput = Pipe()
dump.standardError = Pipe()
try dump.run()
dump.waitUntilExit()
guard dump.terminationStatus == 0 else {
    FileHandle.standardError.write("dump-symbol-graph failed\n".data(using: .utf8)!)
    exit(1)
}

// 2. Locate the emitted Quiver*.symbols.json files. SwiftPM writes to an
//    arch-specific subdir under .build; find any matching file.
let buildDir = URL(fileURLWithPath: quiverPath).appendingPathComponent(".build")
let enumerator = FileManager.default.enumerator(at: buildDir, includingPropertiesForKeys: nil)!
var symbolFiles: [URL] = []
for case let url as URL in enumerator {
    let name = url.lastPathComponent
    if name.hasPrefix("Quiver") && name.hasSuffix(".symbols.json") && !name.contains("Tests") {
        symbolFiles.append(url)
    }
}
print("Found \(symbolFiles.count) symbol-graph files")

// 3. Parse each file and build a flat name -> { signature, summary } map.
//    Overloads: if two symbols share an unqualified name (e.g. `mean` on
//    [Double] and [[Double]]), keep the entry with the longer doc comment.
//    Real overload resolution is a later project.
struct DocEntry {
    let signature: String
    let summary: String?
    var summaryLength: Int { summary?.count ?? 0 }
}

var docs: [String: DocEntry] = [:]
var totalPublic = 0

for file in symbolFiles {
    let data = try Data(contentsOf: file)
    guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
          let symbols = root["symbols"] as? [[String: Any]] else { continue }

    for sym in symbols {
        guard let access = sym["accessLevel"] as? String, access == "public" else { continue }
        guard let names = sym["names"] as? [String: Any],
              let title = names["title"] as? String else { continue }
        totalPublic += 1

        // Unqualified name for Monaco's getWordAtPosition. Strip `(...)`
        // from method titles like `mean()` -> `mean`.
        let key: String
        if let paren = title.firstIndex(of: "(") {
            key = String(title[..<paren])
        } else {
            key = title
        }
        if key.isEmpty { continue }

        // Signature: concatenate declarationFragments spellings. Falls back
        // to the title if fragments are missing.
        var signature = title
        if let frags = sym["declarationFragments"] as? [[String: Any]] {
            let joined = frags.compactMap { $0["spelling"] as? String }.joined()
            if !joined.isEmpty { signature = joined }
        }

        // Summary: first paragraph of the doc comment (lines up to the
        // first blank line). Stop on blank so we skip examples and - Returns.
        var summary: String? = nil
        if let doc = sym["docComment"] as? [String: Any],
           let lines = doc["lines"] as? [[String: Any]] {
            var paragraph: [String] = []
            for line in lines {
                let text = (line["text"] as? String) ?? ""
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty { break }
                paragraph.append(trimmed)
            }
            if !paragraph.isEmpty { summary = paragraph.joined(separator: " ") }
        }

        let entry = DocEntry(signature: signature, summary: summary)
        if let existing = docs[key], existing.summaryLength >= entry.summaryLength {
            continue
        }
        docs[key] = entry
    }
}

// 4. Encode as flat JSON.
var jsonMap: [String: [String: String?]] = [:]
for (k, v) in docs {
    jsonMap[k] = ["signature": v.signature, "summary": v.summary]
}

let data = try JSONSerialization.data(withJSONObject: jsonMap, options: [.prettyPrinted, .sortedKeys])
try data.write(to: URL(fileURLWithPath: outputPath))

print("Scanned \(totalPublic) public symbols")
print("Wrote \(docs.count) entries to \(outputPath)")
print("File size: \(data.count) bytes")
