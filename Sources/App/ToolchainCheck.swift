import Pelican
import Foundation

/// Verifies the host machine has macOS 15+ and a working Swift 5.9+ toolchain before the server boots.
/// Throws a `ToolchainCheck.Failure` with a remediation message if any check fails.
enum ToolchainCheck {

    static let minimumSwiftMajor = 5
    static let minimumSwiftMinor = 9
    static let minimumMacOSMajor = 15
    static let setupDocsURL = "https://waynewbishop.github.io/quiver/documentation/quiver/quiver-notebook"

    struct Failure: Error, CustomStringConvertible {
        let message: String
        var description: String { message }
    }

    /// Runs every startup check in order. Logs success messages so the operator can see what passed.
    static func run(app: Application) throws {
        try checkMacOSVersion(logger: app.logger)
        try checkSwiftToolchain(logger: app.logger)
    }

    private static func checkMacOSVersion(logger: PelicanLogger) throws {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        if version.majorVersion < minimumMacOSMajor {
            throw Failure(message: """
                Quiver Notebook requires macOS \(minimumMacOSMajor) (Sequoia) or newer.
                Detected: macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion).
                See the Quiver Notebook setup guide: \(setupDocsURL)
                """)
        }
        logger.info("macOS \(version.majorVersion).\(version.minorVersion).\(version.patchVersion) — OK")
    }

    private static func checkSwiftToolchain(logger: PelicanLogger) throws {
        let result: (stdout: String, stderr: String, exitCode: Int32)
        do {
            result = try invokeSwiftVersion()
        } catch {
            throw Failure(message: """
                Quiver Notebook could not invoke the Swift toolchain: \(error.localizedDescription).
                Install Swift via swiftly: https://download.swift.org/swiftly/darwin/swiftly-1.1.1.pkg
                Then run: ~/.swiftly/bin/swiftly init
                See the Quiver Notebook setup guide: \(setupDocsURL)
                """)
        }

        let combined = result.stdout + "\n" + result.stderr

        if combined.contains("xcrun: error: invalid active developer path") {
            throw Failure(message: """
                Xcode command-line tools are not installed (or the active developer path is broken).
                The lightest fix is to install swiftly instead: https://download.swift.org/swiftly/darwin/swiftly-1.1.1.pkg
                Then run: ~/.swiftly/bin/swiftly init
                See the Quiver Notebook setup guide: \(setupDocsURL)
                """)
        }

        if combined.contains("Agreeing to the Xcode") || combined.contains("license") && combined.contains("xcodebuild") {
            throw Failure(message: """
                The Xcode license has not been accepted on this machine.
                Run: sudo xcodebuild -license accept
                See the Quiver Notebook setup guide: \(setupDocsURL)
                """)
        }

        if result.exitCode != 0 {
            throw Failure(message: """
                `swift --version` exited with status \(result.exitCode).
                Output: \(combined.trimmingCharacters(in: .whitespacesAndNewlines))
                See the Quiver Notebook setup guide: \(setupDocsURL)
                """)
        }

        guard let (major, minor) = parseSwiftVersion(from: result.stdout) else {
            throw Failure(message: """
                Could not parse Swift version from `swift --version` output.
                Output: \(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines))
                See the Quiver Notebook setup guide: \(setupDocsURL)
                """)
        }

        if (major, minor) < (minimumSwiftMajor, minimumSwiftMinor) {
            throw Failure(message: """
                Quiver Notebook requires Swift \(minimumSwiftMajor).\(minimumSwiftMinor) or newer.
                Detected: Swift \(major).\(minor).
                Upgrade with swiftly: ~/.swiftly/bin/swiftly install latest
                See the Quiver Notebook setup guide: \(setupDocsURL)
                """)
        }

        logger.info("Swift \(major).\(minor) — OK")
    }

    private static func invokeSwiftVersion() throws -> (stdout: String, stderr: String, exitCode: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", "--version"]

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()
        process.waitUntilExit()

        let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return (stdout, stderr, process.terminationStatus)
    }

    /// Parses a line like "Apple Swift version 5.10 (swiftlang-5.10.0.13)" or "Swift version 5.9".
    static func parseSwiftVersion(from output: String) -> (major: Int, minor: Int)? {
        let pattern = #"Swift version (\d+)\.(\d+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(output.startIndex..., in: output)
        guard let match = regex.firstMatch(in: output, range: range), match.numberOfRanges >= 3 else { return nil }
        guard let majorRange = Range(match.range(at: 1), in: output),
              let minorRange = Range(match.range(at: 2), in: output),
              let major = Int(output[majorRange]),
              let minor = Int(output[minorRange]) else { return nil }
        return (major, minor)
    }
}
