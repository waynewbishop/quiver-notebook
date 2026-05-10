import Pelican
import Foundation

@main
struct Entrypoint {
    static func main() async throws {
        let logger = PelicanLogger()
        let port = resolvePort(logger: logger)
        let app = Application(host: "127.0.0.1", port: port)

        do {
            try await configure(app)
        } catch {
            logger.error("Configuration failed: \(error)")
            throw error
        }

        StartupBanner.print(port: app.port)

        do {
            try await app.run()
        } catch {
            let message = "\(error)"
            if message.contains("bind") || message.contains("address") || message.contains("EADDRINUSE") {
                logger.error("Could not bind to port \(app.port). Another process is using it. Run with PORT=8090 swift run App (or any free port).")
            }
            throw error
        }
    }
}
