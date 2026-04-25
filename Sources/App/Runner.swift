import Vapor
import Foundation

/// Executes user-submitted Swift code by writing it into the sandbox package and invoking `swift run`.
enum Runner {

    struct Result {
        let stdout: String
        let stderr: String
        let exitCode: Int32
        let durationMs: Int
    }

    enum RunnerError: Error {
        case sandboxNotFound(String)
        case processFailed(String)
    }

    /// Wraps user code with the Quiver import and an entry point, writes to the sandbox main.swift, then runs it.
    static func run(userCode: String, app: Application) async throws -> Result {
        let sandboxDir = try sandboxDirectory(app: app)
        let mainPath = sandboxDir.appendingPathComponent("Sources/Runner/main.swift")

        let wrapped = wrap(userCode: userCode)
        try wrapped.write(to: mainPath, atomically: true, encoding: .utf8)

        return try await invokeSwiftRun(in: sandboxDir, logger: app.logger)
    }

    /// Triggers a build of the sandbox package with a trivial main.swift so Quiver is compiled and cached.
    static func prewarm(app: Application) async throws -> Result {
        let sandboxDir = try sandboxDirectory(app: app)
        let mainPath = sandboxDir.appendingPathComponent("Sources/Runner/main.swift")

        let stub = wrap(userCode: "// pre-warm\nprint(\"Quiver notebook ready.\")\n")
        try stub.write(to: mainPath, atomically: true, encoding: .utf8)

        return try await invokeSwiftRun(in: sandboxDir, logger: app.logger)
    }

    /// Injects `import Quiver`, Foundation, and a `@main` entry point around user code.
    private static func wrap(userCode: String) -> String {
        return """
        import Quiver
        import Foundation

        // --- user code begins ---
        \(userCode)
        // --- user code ends ---
        """
    }

    /// Locates the sandbox/ directory relative to the Vapor working directory.
    private static func sandboxDirectory(app: Application) throws -> URL {
        let workingDir = app.directory.workingDirectory
        let url = URL(fileURLWithPath: workingDir).appendingPathComponent("sandbox", isDirectory: true)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw RunnerError.sandboxNotFound(url.path)
        }
        return url
    }

    /// Shells out to `swift run Runner` in the given directory and captures stdout/stderr.
    private static func invokeSwiftRun(in directory: URL, logger: Logger) async throws -> Result {
        let start = Date()

        let process = Process()
        process.currentDirectoryURL = directory
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "run", "Runner"]

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()
        process.waitUntilExit()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""
        let durationMs = Int(Date().timeIntervalSince(start) * 1000)

        return Result(
            stdout: stdout,
            stderr: stderr,
            exitCode: process.terminationStatus,
            durationMs: durationMs
        )
    }
}
