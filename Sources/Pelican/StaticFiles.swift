import Foundation

public struct StaticFiles {
    public let publicDirectory: URL

    public init(publicDirectory: URL) {
        self.publicDirectory = publicDirectory
    }

    public func response(forRequestPath path: String) -> HTTPResponse? {
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        guard !trimmed.contains("..") else { return nil }

        let fileURL = publicDirectory.appendingPathComponent(trimmed)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: contentType(for: fileURL.pathExtension))
        return HTTPResponse(status: .ok, headers: headers, body: data)
    }

    private func contentType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html", "htm": return "text/html; charset=utf-8"
        case "css":         return "text/css; charset=utf-8"
        case "js", "mjs":   return "application/javascript; charset=utf-8"
        case "json":        return "application/json"
        case "svg":         return "image/svg+xml"
        case "png":         return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "ico":         return "image/x-icon"
        case "txt":         return "text/plain; charset=utf-8"
        default:            return "application/octet-stream"
        }
    }
}
