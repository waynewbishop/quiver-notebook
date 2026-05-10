import Foundation

public struct AppDirectories: Sendable {
    public let workingDirectory: String
    public let publicDirectory: String
    public let viewsDirectory: String

    public init(
        workingDirectory: String? = nil,
        publicSubpath: String = "Public",
        viewsSubpath: String = "Resources/Views"
    ) {
        let cwd = workingDirectory ?? FileManager.default.currentDirectoryPath
        let normalized = cwd.hasSuffix("/") ? cwd : cwd + "/"
        self.workingDirectory = normalized
        self.publicDirectory = normalized + publicSubpath + "/"
        self.viewsDirectory = normalized + viewsSubpath + "/"
    }
}

public struct PelicanLogger: Sendable {
    public enum Level: String, Sendable { case info, notice, warning, error }

    public init() {}

    public func info(_ message: String)    { emit(.info, message) }
    public func notice(_ message: String)  { emit(.notice, message) }
    public func warning(_ message: String) { emit(.warning, message) }
    public func error(_ message: String)   { emit(.error, message) }

    private func emit(_ level: Level, _ message: String) {
        let line = "[\(level.rawValue)] \(message)\n"
        if level == .error || level == .warning {
            FileHandle.standardError.write(Data(line.utf8))
        } else {
            FileHandle.standardOutput.write(Data(line.utf8))
        }
    }
}

extension Application {
    public var directory: AppDirectories {
        AppDirectories()
    }

    public var logger: PelicanLogger {
        PelicanLogger()
    }
}
