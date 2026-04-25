import Vapor
import Foundation

/// Reads the resolved Quiver version from `sandbox/Package.resolved` so the UI
/// always reflects what `swift run` actually built against.
enum QuiverVersion {

    /// Returns the pinned Quiver version, or "unknown" if the file cannot be read or parsed.
    static func resolved(app: Application) -> String {
        let workingDir = app.directory.workingDirectory
        let url = URL(fileURLWithPath: workingDir)
            .appendingPathComponent("sandbox", isDirectory: true)
            .appendingPathComponent("Package.resolved")

        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let pins = json["pins"] as? [[String: Any]] else {
            return "unknown"
        }

        for pin in pins {
            guard let identity = pin["identity"] as? String, identity == "quiver",
                  let state = pin["state"] as? [String: Any],
                  let version = state["version"] as? String else {
                continue
            }
            return version
        }

        return "unknown"
    }
}
