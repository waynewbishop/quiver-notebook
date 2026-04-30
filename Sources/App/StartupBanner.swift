import Vapor
import Foundation

/// Prints a human-readable startup banner to stdout once Vapor has finished its own
/// startup chatter, so the URL the user needs is the last thing on screen.
enum StartupBanner {

    /// Renders the banner to stdout using the resolved server port.
    static func print(app: Application) {
        let port = app.http.server.configuration.port
        let rule = String(repeating: "=", count: 58)

        let banner = """
        \(rule)
          Quiver Notebook is running.

          Open this URL in your browser:
          http://localhost:\(port)

          If port \(port) is in use, restart with: PORT=8090 swift run
        \(rule)
        """

        Swift.print(banner)
    }
}
