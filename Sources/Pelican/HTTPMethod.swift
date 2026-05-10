import Foundation

public enum HTTPMethod: String, Sendable {
    case GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS

    init?(rawToken: String) {
        self.init(rawValue: rawToken.uppercased())
    }
}
