import Pelican
import Foundation

/// Prints a human-readable startup banner to stdout once the server is bound,
/// so the URL the user needs is the last thing on screen.
enum StartupBanner {

    /// Renders the banner to stdout using the resolved server port.
    static func print(port: Int) {
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
