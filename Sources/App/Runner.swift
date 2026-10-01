import Pelican
import Foundation

/// Executes user-submitted Swift code by writing it into the sandbox package, building it, and running the binary.
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

    /// Lines `wrap(userCode:)` places above the user's code; compiler line numbers subtract this to match the editor.
    static let wrapperLineCount = 4

    /// Remembers the sandbox's build products directory, since asking SwiftPM costs about half a second.
    private static let binaryCache = BinaryCache()

    /// Wraps user code with the Quiver import and an entry point, writes to the sandbox main.swift, then runs it.
    static func run(userCode: String, app: Application) async throws -> Result {
        let sandboxDir = try sandboxDirectory(app: app)
        let mainPath = sandboxDir.appendingPathComponent("Sources/Runner/main.swift")

        let wrapped = wrap(userCode: userCode)
        try wrapped.write(to: mainPath, atomically: true, encoding: .utf8)

        return try buildAndRun(in: sandboxDir, userLineCount: userCode.components(separatedBy: "\n").count)
    }

    /// Triggers a build of the sandbox package with a trivial main.swift so Quiver is compiled and cached.
    static func prewarm(app: Application) async throws -> Result {
        let sandboxDir = try sandboxDirectory(app: app)
        let mainPath = sandboxDir.appendingPathComponent("Sources/Runner/main.swift")

        let stubCode = "// pre-warm\nprint(\"Quiver notebook ready.\")\n"
        try wrap(userCode: stubCode).write(to: mainPath, atomically: true, encoding: .utf8)

        return try buildAndRun(in: sandboxDir, userLineCount: stubCode.components(separatedBy: "\n").count)
    }

    /// Injects `import Quiver`, Foundation, line-buffered stdout, and the user's code into the sandbox's main.swift.
    /// Keep `wrapperLineCount` in sync with the number of lines above the user's code.
    static func wrap(userCode: String) -> String {
        return """
        import Quiver
        import Foundation
        setvbuf(stdout, nil, _IOLBF, 0)  // keeps printed lines when the program crashes
        // --- user code begins ---
        \(userCode)
        // --- user code ends ---
        """
    }

    /// Locates the sandbox/ directory relative to the application's working directory.
    private static func sandboxDirectory(app: Application) throws -> URL {
        let workingDir = app.directory.workingDirectory
        let url = URL(fileURLWithPath: workingDir).appendingPathComponent("sandbox", isDirectory: true)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw RunnerError.sandboxNotFound(url.path)
        }
        return url
    }

    /// Builds the sandbox and, if that succeeds, runs the Runner binary so build noise never mixes with program output.
    /// Failed builds return only the compiler diagnostics; set `QUIVER_NOTEBOOK_DEBUG=1` to see the full build output.
    private static func buildAndRun(in directory: URL, userLineCount: Int) throws -> Result {
        let start = Date()
        let debugEnabled = ProcessInfo.processInfo.environment["QUIVER_NOTEBOOK_DEBUG"] == "1"

        let build = try execute(["swift", "build", "--no-color-diagnostics", "--product", "Runner"], in: directory)
        let buildOutput = build.stdout + build.stderr

        guard build.exitCode == 0 else {
            let diagnostics = debugEnabled
                ? buildOutput
                : BuildDiagnostics.clean(buildOutput, wrapperLineCount: wrapperLineCount, userLineCount: userLineCount)
            return Result(stdout: "", stderr: diagnostics, exitCode: build.exitCode, durationMs: elapsedMs(since: start))
        }

        // Run from the sandbox directory so bundled datasets resolve their relative paths.
        let program = try execute([try runnerBinary(in: directory).path], in: directory)

        return Result(
            stdout: program.stdout,
            stderr: debugEnabled ? buildOutput + program.stderr : program.stderr,
            exitCode: program.exitCode,
            durationMs: elapsedMs(since: start)
        )
    }

    /// Returns the path to the built Runner executable, asking SwiftPM for the products directory once.
    private static func runnerBinary(in directory: URL) throws -> URL {
        if let cached = binaryCache.url {
            return cached
        }
        let output = try execute(["swift", "build", "--show-bin-path"], in: directory)
        let binPath = output.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        guard output.exitCode == 0, !binPath.isEmpty else {
            throw RunnerError.processFailed("Could not locate the sandbox build directory: \(output.stderr)")
        }
        let url = URL(fileURLWithPath: binPath).appendingPathComponent("Runner")
        binaryCache.store(url)
        return url
    }

    /// Runs a command in the given directory and captures stdout, stderr, and the exit code.
    private static func execute(_ command: [String], in directory: URL) throws -> (stdout: String, stderr: String, exitCode: Int32) {
        let process = Process()
        process.currentDirectoryURL = directory
        if command.first?.hasPrefix("/") == true {
            process.executableURL = URL(fileURLWithPath: command[0])
            process.arguments = Array(command.dropFirst())
        } else {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = command
        }

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()

        // Drain stderr on another thread while reading stdout, so neither pipe can fill up and stall the process.
        let stderrHandle = stderrPipe.fileHandleForReading
        let stderrBuffer = DataBuffer()
        let stderrDone = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            stderrBuffer.data = stderrHandle.readDataToEndOfFile()
            stderrDone.signal()
        }
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        stderrDone.wait()
        process.waitUntilExit()

        // A crash ends the process with a signal; report it as 128 + signal, the way shells and `swift run` do.
        let exitCode = process.terminationReason == .uncaughtSignal
            ? 128 + process.terminationStatus
            : process.terminationStatus

        return (
            String(decoding: stdoutData, as: UTF8.self),
            String(decoding: stderrBuffer.data, as: UTF8.self),
            exitCode
        )
    }

    /// Milliseconds elapsed since the given start time.
    private static func elapsedMs(since start: Date) -> Int {
        Int(Date().timeIntervalSince(start) * 1000)
    }
}

/// Holds data written by one thread and read by another after a semaphore handoff.
private final class DataBuffer: @unchecked Sendable {
    var data = Data()
}

/// Thread-safe storage for the Runner binary's location.
private final class BinaryCache: @unchecked Sendable {
    private let lock = NSLock()
    private var _url: URL?

    var url: URL? {
        lock.lock(); defer { lock.unlock() }
        return _url
    }

    func store(_ url: URL) {
        lock.lock(); defer { lock.unlock() }
        _url = url
    }
}
