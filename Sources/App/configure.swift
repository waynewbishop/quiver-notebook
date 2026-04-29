import Vapor
import Leaf
import Foundation

/// Configures Vapor application: serves static files, renders Leaf views, and pre-warms the sandbox build cache.
public func configure(_ app: Application) async throws {
    // Serve static assets from Public/
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Use Leaf as the view renderer
    app.views.use(.leaf)

    // Point Leaf at Resources/Views (Vapor default)
    app.leaf.configuration.rootDirectory = app.directory.viewsDirectory

    // Listen on localhost only — this tool runs on the user's machine, never exposed externally
    app.http.server.configuration.hostname = "127.0.0.1"

    // Resolve the port: PORT env var wins, default 8080. Validate it's a usable TCP port.
    let port = resolvePort(logger: app.logger)
    app.http.server.configuration.port = port

    // Refuse to start if the hostname has drifted from localhost. The notebook runs untrusted
    // Swift by design; binding to anything other than 127.0.0.1 would expose that to the network.
    precondition(
        app.http.server.configuration.hostname == "127.0.0.1",
        "Quiver Notebook must bind to 127.0.0.1 only. See README → Running the Notebook Safely."
    )

    try routes(app)

    app.logger.notice("Server started on http://localhost:\(port)")
    app.logger.notice("If port \(port) is already in use, set the PORT env var: PORT=8090 swift run App")

    // Kick off a sandbox pre-warm in the background so the first user Run is fast.
    // Status is exposed via GET /api/status so the frontend can show a "warming up" banner.
    PrewarmStatus.shared.markRunning()
    app.logger.info("Pre-warming sandbox build cache (this may take ~1-2 minutes on first run)...")
    Task.detached {
        do {
            _ = try await Runner.prewarm(app: app)
            PrewarmStatus.shared.markReady()
            app.logger.info("Sandbox pre-warm complete. Notebook is ready.")
        } catch {
            PrewarmStatus.shared.markFailed(reason: "\(error)")
            app.logger.warning("Sandbox pre-warm failed: \(error). First Run will be slow.")
        }
    }
}

/// Reads PORT from the environment, falls back to 8080. Logs the choice so users can see it.
private func resolvePort(logger: Logger) -> Int {
    if let raw = ProcessInfo.processInfo.environment["PORT"], !raw.isEmpty {
        if let parsed = Int(raw), (1...65535).contains(parsed) {
            logger.info("Using PORT=\(parsed) from environment.")
            return parsed
        }
        logger.warning("PORT env var '\(raw)' is not a valid TCP port (1–65535). Falling back to 8080.")
    }
    return 8080
}
