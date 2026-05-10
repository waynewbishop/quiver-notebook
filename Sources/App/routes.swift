import Pelican
import Foundation

/// Registers HTTP routes: the editor page, the run endpoint, and the examples listing.
func routes(_ app: Application) throws {
    let directories = AppDirectories()
    let viewsDirectory = URL(fileURLWithPath: directories.viewsDirectory, isDirectory: true)
    let publicDirectory = URL(fileURLWithPath: directories.publicDirectory, isDirectory: true)
    let staticFiles = StaticFiles(publicDirectory: publicDirectory)

    // Render the notebook editor (replaces Leaf with two String replacements).
    app.get("/") { req in
        let version = QuiverVersion.resolved(app: app)
        let templateURL = viewsDirectory.appendingPathComponent("editor.html")
        let template = try String(contentsOf: templateURL, encoding: .utf8)
        let html = template
            .replacingOccurrences(of: "#(title)", with: "Quiver Notebook")
            .replacingOccurrences(of: "#(quiverVersion)", with: version)
        return HTTPResponse.html(html)
    }

    // Execute user Swift code in the sandbox package.
    app.post("/api/run") { req in
        let payload = try req.decode(RunRequest.self)
        let result = try await Runner.run(userCode: payload.code, app: app)
        let body = RunResponse(
            stdout: result.stdout,
            stderr: result.stderr,
            exitCode: result.exitCode,
            durationMs: result.durationMs
        )
        return try HTTPResponse.json(body)
    }

    // Report the sandbox pre-warm status so the frontend can show a "warming up" banner.
    app.get("/api/status") { req in
        let status = PrewarmStatus.shared
        let body = StatusResponse(prewarm: status.state.rawValue, reason: status.reason)
        return try HTTPResponse.json(body)
    }

    // List example snippets discovered in the examples/ directory.
    app.get("/api/examples") { req in
        let examples = try Examples.list(app: app)
        return try HTTPResponse.json(examples)
    }

    // Return the source of a single example by filename.
    app.get("/api/examples/:name") { req in
        guard let name = req.parameter("name") else {
            return HTTPResponse.text("Missing example name", status: .badRequest)
        }
        let detail = try Examples.load(name: name, app: app)
        return try HTTPResponse.json(detail)
    }

    // Static files (CSS, JS, favicon, quiver-docs.json) — served from /Public.
    // FileMiddleware-equivalent: any GET that didn't match a route above falls through here.
    app.get("/favicon.svg")        { _ in staticFiles.response(forRequestPath: "favicon.svg") ?? .notFound() }
    app.get("/quiver-docs.json")   { _ in staticFiles.response(forRequestPath: "quiver-docs.json") ?? .notFound() }
    app.get("/css/:file")          { req in
        guard let file = req.parameter("file") else { return .notFound() }
        return staticFiles.response(forRequestPath: "css/\(file)") ?? .notFound()
    }
    app.get("/js/:file")           { req in
        guard let file = req.parameter("file") else { return .notFound() }
        return staticFiles.response(forRequestPath: "js/\(file)") ?? .notFound()
    }
}

struct RunRequest: Codable {
    let code: String
}

struct RunResponse: Codable {
    let stdout: String
    let stderr: String
    let exitCode: Int32
    let durationMs: Int
}

struct StatusResponse: Codable {
    let prewarm: String
    let reason: String?
}

struct ExampleSummary: Codable {
    let name: String
    let title: String
}

struct ExampleDetail: Codable {
    let name: String
    let title: String
    let code: String
}
