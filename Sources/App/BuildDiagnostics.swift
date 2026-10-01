import Foundation

/// Turns raw `swift build` output into compiler messages whose line numbers match the editor.
enum BuildDiagnostics {

    /// Returns the diagnostics for a failed build, renumbered to the user's code, or the readable remainder when none match.
    static func clean(_ raw: String, wrapperLineCount: Int, userLineCount: Int) -> String {
        let lines = raw.components(separatedBy: "\n").map(stripColor)
        let userLines = (wrapperLineCount + 1)...(wrapperLineCount + max(userLineCount, 1))
        let blocks = diagnosticBlocks(in: lines, userLines: userLines, offset: wrapperLineCount)
        guard !blocks.isEmpty else { return fallback(lines) }

        // The emit-module and compile jobs can both report the same diagnostic.
        var seen = Set<String>()
        return blocks.filter { seen.insert($0).inserted }.joined(separator: "\n\n")
    }

    /// Removes ANSI color codes, which the build system can add even when color is turned off.
    private static func stripColor(_ line: String) -> String {
        line.replacing(#/\x1B\[[0-9;]*m/#, with: "")
    }

    /// Collects each `main.swift:L:C:` diagnostic and its code excerpt, keeping only rows from the user's code.
    private static func diagnosticBlocks(in lines: [String], userLines: ClosedRange<Int>, offset: Int) -> [String] {
        let headerPattern = #/\S*main\.swift:(?<line>\d+):(?<column>\d+): (?<kind>error|warning|note): (?<message>.*)/#
        let excerptPattern = #/\s*(?<number>\d+) \|(?<text>.*)/#
        let markerPattern = #/\s*\|(?<text>.*)/#

        var blocks: [String] = []
        var header: String?
        var excerpt: [(number: Int?, text: String)] = []
        var keepMarkers = false

        /// Appends the current diagnostic, padding the excerpt gutter to the width of the renumbered lines.
        func finishBlock() {
            guard let current = header else { return }
            let width = excerpt.compactMap(\.number).map { String($0).count }.max() ?? 0
            let rows = excerpt.map { row in
                let gutter = row.number.map(String.init) ?? ""
                return String(repeating: " ", count: width - gutter.count) + gutter + " |" + row.text
            }
            blocks.append(([current] + rows).joined(separator: "\n"))
            header = nil
            excerpt = []
            keepMarkers = false
        }

        for line in lines {
            if let match = line.wholeMatch(of: headerPattern) {
                finishBlock()
                var location = ""
                if let wrappedLine = Int(match.line), userLines.contains(wrappedLine) {
                    location = "line \(wrappedLine - offset):\(match.column): "
                }
                header = "\(location)\(match.kind): \(match.message)"
            } else if header != nil, let match = line.wholeMatch(of: excerptPattern) {
                // Rows from the wrapper (imports, begin/end comments) are dropped along with their markers.
                keepMarkers = Int(match.number).map(userLines.contains) ?? false
                if keepMarkers, let number = Int(match.number) {
                    excerpt.append((number - offset, String(match.text)))
                }
            } else if header != nil, let match = line.wholeMatch(of: markerPattern) {
                if keepMarkers {
                    excerpt.append((nil, String(match.text)))
                }
            } else {
                finishBlock()
            }
        }
        finishBlock()
        return blocks
    }

    /// Keeps linker and package errors readable by dropping progress lines, command dumps, and sandbox paths.
    private static func fallback(_ lines: [String]) -> String {
        let progressPattern = #/Building for .*|\[\d+\D+\d+\] .*|Build complete.*|Failed frontend command:/#
        var kept: [String] = []
        var inCommandDump = false

        for line in lines {
            // "error: <job> failed with a nonzero exit code. Command line:" is followed by indented invocations.
            if line.contains("failed with a nonzero exit code") {
                inCommandDump = true
                continue
            }
            if inCommandDump, line.isEmpty || line.first?.isWhitespace == true {
                continue
            }
            inCommandDump = false
            if line.isEmpty || line.wholeMatch(of: progressPattern) != nil || line.contains("swift-frontend -frontend") {
                continue
            }
            // "…/sandbox/Package.swift: Runner-product: clang: error: …" becomes "clang: error: …".
            if let range = line.range(of: "Runner-product: ") {
                kept.append(String(line[range.upperBound...]))
            } else {
                kept.append(line)
            }
        }

        // Never hide a failure behind an empty pane: show the raw output if filtering removed everything.
        return kept.isEmpty ? lines.joined(separator: "\n") : kept.joined(separator: "\n")
    }
}
