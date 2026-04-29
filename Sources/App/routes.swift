import Vapor

/// Registers HTTP routes: the editor page, the run endpoint, and the examples listing.
func routes(_ app: Application) throws {
    // Render the notebook editor
    app.get { req async throws -> View in
        let version = QuiverVersion.resolved(app: req.application)
        return try await req.view.render("editor", EditorContext(title: "Quiver Notebook", quiverVersion: version))
    }

    // Execute user Swift code in the sandbox package
    app.post("api", "run") { req async throws -> RunResponse in
        let payload = try req.content.decode(RunRequest.self)
        let result = try await Runner.run(userCode: payload.code, app: req.application)
        return RunResponse(
            stdout: result.stdout,
            stderr: result.stderr,
            exitCode: result.exitCode,
            durationMs: result.durationMs
        )
    }

    // Report the sandbox pre-warm status so the frontend can show a "warming up" banner.
    app.get("api", "status") { req async throws -> StatusResponse in
        let status = PrewarmStatus.shared
        return StatusResponse(prewarm: status.state.rawValue, reason: status.reason)
    }

    // List example snippets discovered in the examples/ directory
    app.get("api", "examples") { req async throws -> [ExampleSummary] in
        try Examples.list(app: req.application)
    }

    // Return the source of a single example by filename
    app.get("api", "examples", ":name") { req async throws -> ExampleDetail in
        guard let name = req.parameters.get("name") else {
            throw Abort(.badRequest, reason: "Missing example name")
        }
        return try Examples.load(name: name, app: req.application)
    }
}

struct EditorContext: Encodable {
    let title: String
    let quiverVersion: String
}

struct RunRequest: Content {
    let code: String
}

struct RunResponse: Content {
    let stdout: String
    let stderr: String
    let exitCode: Int32
    let durationMs: Int
}

struct StatusResponse: Content {
    let prewarm: String
    let reason: String?
}

struct ExampleSummary: Content {
    let name: String
    let title: String
}

struct ExampleDetail: Content {
    let name: String
    let title: String
    let code: String
}
