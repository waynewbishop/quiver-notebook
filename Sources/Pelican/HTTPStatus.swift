import Foundation

public struct HTTPStatus: Sendable, Equatable {
    public let code: Int
    public let reason: String

    public init(code: Int, reason: String) {
        self.code = code
        self.reason = reason
    }

    public static let ok = HTTPStatus(code: 200, reason: "OK")
    public static let created = HTTPStatus(code: 201, reason: "Created")
    public static let noContent = HTTPStatus(code: 204, reason: "No Content")
    public static let badRequest = HTTPStatus(code: 400, reason: "Bad Request")
    public static let notFound = HTTPStatus(code: 404, reason: "Not Found")
    public static let methodNotAllowed = HTTPStatus(code: 405, reason: "Method Not Allowed")
    public static let payloadTooLarge = HTTPStatus(code: 413, reason: "Payload Too Large")
    public static let internalServerError = HTTPStatus(code: 500, reason: "Internal Server Error")
}
