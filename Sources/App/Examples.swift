import Pelican
import Foundation

/// Reads example `.swift` files from the examples/ directory and serves them to the frontend.
enum Examples {

    enum ExamplesError: Error {
        case directoryNotFound(String)
        case fileNotFound(String)
        case invalidName
    }

    /// Lists all example files, deriving a display title from the first line comment when present.
    static func list(app: Application) throws -> [ExampleSummary] {
        let dir = try examplesDirectory(app: app)
        let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
            .filter { $0.hasSuffix(".swift") }
            .sorted()

        return try files.map { filename in
            let url = dir.appendingPathComponent(filename)
            let contents = try String(contentsOf: url, encoding: .utf8)
            let title = extractTitle(from: contents) ?? defaultTitle(from: filename)
            return ExampleSummary(name: filename, title: title)
        }
    }

    /// Loads the full source of one example by filename, rejecting anything that escapes the examples directory.
    static func load(name: String, app: Application) throws -> ExampleDetail {
        guard isSafeFilename(name) else {
            throw ExamplesError.invalidName
        }
        let dir = try examplesDirectory(app: app)
        let url = dir.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ExamplesError.fileNotFound(name)
        }
        let contents = try String(contentsOf: url, encoding: .utf8)
        let title = extractTitle(from: contents) ?? defaultTitle(from: name)
        return ExampleDetail(name: name, title: title, code: contents)
    }

    /// Locates the examples/ directory relative to the Vapor working directory.
    private static func examplesDirectory(app: Application) throws -> URL {
        let workingDir = app.directory.workingDirectory
        let url = URL(fileURLWithPath: workingDir).appendingPathComponent("examples", isDirectory: true)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ExamplesError.directoryNotFound(url.path)
        }
        return url
    }

    /// Pulls the first `// Title: ...` line out of the source, used as the display title.
    private static func extractTitle(from source: String) -> String? {
        for line in source.split(separator: "\n", maxSplits: 5, omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("// Title:") {
                return String(trimmed.dropFirst("// Title:".count)).trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    /// Falls back to a humanized filename when no title comment is present.
    private static func defaultTitle(from filename: String) -> String {
        let base = filename.replacingOccurrences(of: ".swift", with: "")
        return base.replacingOccurrences(of: "-", with: " ").capitalized
    }

    /// Rejects filenames containing path separators or parent-directory references.
    private static func isSafeFilename(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        guard !name.contains("/") else { return false }
        guard !name.contains("\\") else { return false }
        guard !name.contains("..") else { return false }
        return name.hasSuffix(".swift")
    }
}
