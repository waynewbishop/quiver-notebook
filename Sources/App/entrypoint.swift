import Vapor

@main
struct Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        let app = try await Application.make(env)

        do {
            try await configure(app)
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }

        do {
            // Inline the body of `app.execute()` so we can print the startup banner
            // *between* server-start (which logs "Server started on ...") and the
            // long-lived wait on `running.onStop`. This makes the banner the last
            // thing on screen, with the URL visible to the user.
            try await app.startup()
            StartupBanner.print(app: app)
            try await app.running?.onStop.get()
        } catch {
            // Most common failure here is bind-to-port. Surface the workaround inline.
            let message = "\(error)"
            if message.contains("bind") || message.contains("address") || message.contains("EADDRINUSE") {
                let port = app.http.server.configuration.port
                app.logger.error("Could not bind to port \(port). Another process is using it. Run with PORT=8090 swift run App (or any free port).")
            }
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }

        try await app.asyncShutdown()
    }
}
