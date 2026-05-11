import Pelican
import Foundation

/// Reads example `.swift` files from the bundled examples/ directory and the
/// user-managed examples-custom/ directory. Custom examples appear after bundled ones.
enum Examples {

    enum ExamplesError: Error {
        case directoryNotFound(String)
        case fileNotFound(String)
        case invalidName
    }

    enum Source: String {
        case bundled
        case custom
    }

    /// Lists bundled examples first, then custom examples. Custom entries have their title prefixed with "Custom — ".
    static func list(app: Application) throws -> [ExampleSummary] {
        let bundled = try summaries(in: bundledDirectory(app: app), source: .bundled)
        let custom = (try? summaries(in: customDirectory(app: app), source: .custom)) ?? []
        return bundled + custom
    }

    /// Loads the full source of one example by filename. Looks in custom/ first, then bundled/.
    static func load(name: String, app: Application) throws -> ExampleDetail {
        guard isSafeFilename(name) else {
            throw ExamplesError.invalidName
        }

        if let url = locate(name: name, in: customDirectory(app: app)) {
            return try makeDetail(name: name, url: url, source: .custom)
        }
        if let url = locate(name: name, in: try bundledDirectory(app: app)) {
            return try makeDetail(name: name, url: url, source: .bundled)
        }
        throw ExamplesError.fileNotFound(name)
    }

    /// Returns example summaries for one directory, applying the source-specific title decoration.
    private static func summaries(in dir: URL, source: Source) throws -> [ExampleSummary] {
        guard FileManager.default.fileExists(atPath: dir.path) else { return [] }

        let files = try FileManager.default.contentsOfDirectory(atPath: dir.path)
            .filter { $0.hasSuffix(".swift") }
            .sorted()

        return try files.map { filename in
            let url = dir.appendingPathComponent(filename)
            let contents = try String(contentsOf: url, encoding: .utf8)
            let baseTitle = extractTitle(from: contents) ?? defaultTitle(from: filename)
            let title = (source == .custom) ? "Custom — \(baseTitle)" : baseTitle
            return ExampleSummary(name: filename, title: title)
        }
    }

    /// Returns the URL of `name` inside `dir` if the file exists; nil otherwise.
    private static func locate(name: String, in dir: URL) -> URL? {
        let url = dir.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    /// Builds an ExampleDetail by reading the file and extracting its title.
    private static func makeDetail(name: String, url: URL, source: Source) throws -> ExampleDetail {
        let contents = try String(contentsOf: url, encoding: .utf8)
        let baseTitle = extractTitle(from: contents) ?? defaultTitle(from: name)
        let title = (source == .custom) ? "Custom — \(baseTitle)" : baseTitle
        return ExampleDetail(name: name, title: title, code: contents)
    }

    /// Locates the bundled examples/ directory shipped with the repo.
    private static func bundledDirectory(app: Application) throws -> URL {
        let workingDir = app.directory.workingDirectory
        let url = URL(fileURLWithPath: workingDir).appendingPathComponent("examples", isDirectory: true)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw ExamplesError.directoryNotFound(url.path)
        }
        return url
    }

    /// Locates the user-managed examples-custom/ directory. Missing folder is fine — returns the URL anyway.
    private static func customDirectory(app: Application) -> URL {
        let workingDir = app.directory.workingDirectory
        return URL(fileURLWithPath: workingDir).appendingPathComponent("examples-custom", isDirectory: true)
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
