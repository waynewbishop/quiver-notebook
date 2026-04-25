import Vapor
import Leaf

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
    app.http.server.configuration.port = 8080

    // Refuse to start if the hostname has drifted from localhost. The notebook runs untrusted
    // Swift by design; binding to anything other than 127.0.0.1 would expose that to the network.
    precondition(
        app.http.server.configuration.hostname == "127.0.0.1",
        "Quiver Notebook must bind to 127.0.0.1 only. See README → Running the Notebook Safely."
    )

    try routes(app)

    app.logger.notice("Server started on http://localhost:8080")

    // Kick off a sandbox pre-warm in the background so the first user Run is fast.
    app.logger.info("Pre-warming sandbox build cache (this may take ~1-2 minutes on first run)...")
    Task.detached {
        do {
            _ = try await Runner.prewarm(app: app)
            app.logger.info("Sandbox pre-warm complete. Notebook is ready.")
        } catch {
            app.logger.warning("Sandbox pre-warm failed: \(error). First Run will be slow.")
        }
    }
}
