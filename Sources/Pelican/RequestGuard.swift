import Foundation

/// Rejects requests that did not come from the Notebook's own page on this machine.
///
/// Binding to 127.0.0.1 keeps other machines out, but a web page open in the user's
/// browser can still send requests to localhost. The guard closes that path with four checks:
/// the Host header must name this server (blocks DNS rebinding), any Origin header must be
/// this server (blocks cross-site requests), state-changing requests must be JSON (forces a
/// CORS preflight, which Pelican never approves), and, when a session token is set,
/// state-changing requests must carry it.
public struct RequestGuard: Sendable {
    /// Header that carries the per-session token on state-changing requests.
    public static let tokenHeader = "X-Notebook-Token"

    private let port: Int
    private let sessionToken: String?

    public init(port: Int, sessionToken: String? = nil) {
        self.port = port
        self.sessionToken = sessionToken
    }

    /// Returns an error response when the request should be refused, or nil when it may proceed.
    public func rejection(for request: HTTPRequest) -> HTTPResponse? {
        guard let host = request.headers.first(name: "Host"), isAllowedHost(host) else {
            return HTTPResponse.text("Forbidden: unrecognized Host header", status: .forbidden)
        }

        if let origin = request.headers.first(name: "Origin"), !isAllowedOrigin(origin) {
            return HTTPResponse.text("Forbidden: cross-origin request", status: .forbidden)
        }

        guard isStateChanging(request.method) else { return nil }

        guard let contentType = request.headers.first(name: "Content-Type"), isJSON(contentType) else {
            return HTTPResponse.text("Unsupported Media Type: expected application/json", status: .unsupportedMediaType)
        }

        if let sessionToken {
            guard let presented = request.headers.first(name: Self.tokenHeader),
                  constantTimeEquals(presented, sessionToken) else {
                return HTTPResponse.text("Forbidden: missing or invalid session token", status: .forbidden)
            }
        }

        return nil
    }

    /// Accepts localhost or 127.0.0.1, with no port or this server's port.
    private func isAllowedHost(_ value: String) -> Bool {
        let host = value.trimmingCharacters(in: .whitespaces).lowercased()
        let allowed = ["localhost", "127.0.0.1"]
        return allowed.contains(host) || allowed.contains { host == "\($0):\(port)" }
    }

    /// Accepts only this server's own origin; "null" and every other origin are refused.
    private func isAllowedOrigin(_ value: String) -> Bool {
        let origin = value.trimmingCharacters(in: .whitespaces).lowercased()
        return origin == "http://localhost:\(port)" || origin == "http://127.0.0.1:\(port)"
    }

    /// Reports whether the method can change server state.
    private func isStateChanging(_ method: HTTPMethod) -> Bool {
        switch method {
        case .POST, .PUT, .PATCH, .DELETE:
            return true
        case .GET, .HEAD, .OPTIONS:
            return false
        }
    }

    /// Reports whether a Content-Type value is JSON, ignoring parameters such as charset.
    private func isJSON(_ value: String) -> Bool {
        let mediaType = value.split(separator: ";").first.map(String.init) ?? ""
        return mediaType.trimmingCharacters(in: .whitespaces).lowercased() == "application/json"
    }

    /// Compares two strings without exiting early, so timing doesn't reveal the token.
    private func constantTimeEquals(_ lhs: String, _ rhs: String) -> Bool {
        let a = Array(lhs.utf8)
        let b = Array(rhs.utf8)
        guard a.count == b.count else { return false }
        var difference: UInt8 = 0
        for index in a.indices {
            difference |= a[index] ^ b[index]
        }
        return difference == 0
    }
}
