import Foundation

public struct HTTPRequest: Sendable {
    public let method: HTTPMethod
    public let path: String
    public let query: [String: String]
    public let headers: HTTPHeaders
    public let body: Data
    public internal(set) var pathParameters: [String: String]

    public init(
        method: HTTPMethod,
        path: String,
        query: [String: String] = [:],
        headers: HTTPHeaders = HTTPHeaders(),
        body: Data = Data(),
        pathParameters: [String: String] = [:]
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
        self.pathParameters = pathParameters
    }

    public func parameter(_ name: String) -> String? {
        pathParameters[name]
    }

    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: body)
    }
}
