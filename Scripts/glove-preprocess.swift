#!/usr/bin/env swift
// glove-preprocess.swift
// Slice the top-25,000 most-frequent words from a frequency-sorted GloVe-50d
// source file and emit a CSV tailored for the Notebook's WordEmbeddings type.
//
// The source file ships sorted by corpus frequency (most common first), so
// taking the first 25,000 lines yields the top-25K slice. Each source line is
// space-delimited: `word v1 v2 ... v50`.
//
// Output schema:
//
//     word,rank,magnitude,dim_01,dim_02,...,dim_50
//
// Derived columns (computed once at build time so students see useful
// metadata in head() without paying compute on load):
//
//   * rank      — 1-based corpus frequency rank ("the" = 1).
//   * magnitude — vector L2 norm. Function words have lower norms than
//                 content words; correlates weakly with specificity.
//
// No `nearest` column is stored. Nearest-neighbor and analogy queries are
// computed at runtime from the loaded vectors (EmbeddingsDataset.nearest /
// .analogy / .nearestWord), so precomputing and shipping a neighbor column
// would only duplicate that math while forcing an O(n²) build pass and
// inflating the committed file. The cache was dropped deliberately.
//
// Word ordering in the CSV file is by corpus frequency. The WordEmbeddings
// loader treats the file as a lookup table, so order in the file controls
// head() ordering but not lookup behavior.
//
// Usage: swift Scripts/glove-preprocess.swift
//
// Reads:  /Users/waynebishop/Projects/swift-algorithms/Planning/assets/glove.6B.50d.txt
// Writes: /Users/waynebishop/Projects/quiver-notebook/sandbox/Resources/Datasets/glove-50d.csv

import Foundation

let sourcePath = "/Users/waynebishop/Projects/swift-algorithms/Planning/assets/glove.6B.50d.txt"
let outputPath = "/Users/waynebishop/Projects/quiver-notebook/sandbox/Resources/Datasets/glove-50d.csv"
let wordCount = 25_000
let dimCount = 50

guard let sourceData = FileManager.default.contents(atPath: sourcePath),
      let sourceText = String(data: sourceData, encoding: .utf8) else {
    FileHandle.standardError.write(Data("glove-preprocess: cannot read \(sourcePath)\n".utf8))
    exit(1)
}

// Wraps a string in RFC 4180 quoting when the value contains a comma,
// double quote, or whitespace; doubles any internal double quotes.
func csvEscape(_ field: String) -> String {
    let needsQuoting = field.contains(",")
        || field.contains("\"")
        || field.contains(where: { $0.isWhitespace })
    guard needsQuoting else { return field }
    let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
    return "\"\(escaped)\""
}

// Pass 1: parse the source file into parallel arrays.
var words: [String] = []
words.reserveCapacity(wordCount)
var vectors: [[Double]] = []
vectors.reserveCapacity(wordCount)

sourceText.enumerateLines { line, stop in
    let parts = line.split(separator: " ", omittingEmptySubsequences: false)
    guard parts.count == dimCount + 1 else {
        FileHandle.standardError.write(Data(
            "glove-preprocess: malformed line \(words.count + 1) — \(parts.count) fields\n".utf8
        ))
        stop = true
        return
    }
    words.append(String(parts[0]))
    var v: [Double] = []
    v.reserveCapacity(dimCount)
    for i in 1...dimCount {
        v.append(Double(parts[i]) ?? 0.0)
    }
    vectors.append(v)
    if words.count >= wordCount { stop = true }
}

guard words.count == wordCount else {
    FileHandle.standardError.write(Data(
        "glove-preprocess: only parsed \(words.count) of \(wordCount) words\n".utf8
    ))
    exit(1)
}

print("glove-preprocess: parsed \(words.count) words")

// Pass 2: precompute magnitudes (vector L2 norm). O(n) — a cheap cached
// column. Nearest-neighbor is no longer precomputed; it is computed at query
// time from the loaded vectors, so the former O(n²) build pass is gone.
var magnitudes = [Double](repeating: 0.0, count: wordCount)
for i in 0..<wordCount {
    var sumSq = 0.0
    for d in 0..<dimCount { sumSq += vectors[i][d] * vectors[i][d] }
    magnitudes[i] = sqrt(sumSq)
}

print("glove-preprocess: computed magnitudes")

// Pass 3: write the CSV.
var headerFields: [String] = ["word", "rank", "magnitude"]
for i in 1...dimCount {
    headerFields.append(String(format: "dim_%02d", i))
}

var lines: [String] = [headerFields.joined(separator: ",")]
var quotedTokens: [String] = []

for i in 0..<wordCount {
    let word = words[i]
    let escapedWord = csvEscape(word)
    if escapedWord != word { quotedTokens.append(word) }

    var fields: [String] = [
        escapedWord,
        String(i + 1),                                 // rank (1-based)
        String(format: "%.6f", magnitudes[i])          // magnitude
    ]
    for d in 0..<dimCount {
        fields.append(String(vectors[i][d]))
    }
    lines.append(fields.joined(separator: ","))
}

let output = lines.joined(separator: "\n") + "\n"
do {
    try output.write(toFile: outputPath, atomically: true, encoding: .utf8)
} catch {
    FileHandle.standardError.write(Data(
        "glove-preprocess: write failed — \(error)\n".utf8
    ))
    exit(1)
}

print("glove-preprocess: wrote \(wordCount) rows to \(outputPath)")
print("glove-preprocess: \(quotedTokens.count) tokens needed RFC 4180 quoting")
if !quotedTokens.isEmpty && quotedTokens.count <= 20 {
    print("glove-preprocess: quoted tokens — \(quotedTokens.joined(separator: ", "))")
}
