import Foundation

public struct HTTPResponse: Sendable {
    public var status: HTTPStatus
    public var headers: HTTPHeaders
    public var body: Data

    public init(status: HTTPStatus = .ok, headers: HTTPHeaders = HTTPHeaders(), body: Data = Data()) {
        self.status = status
        self.headers = headers
        self.body = body
    }

    public static func text(_ string: String, status: HTTPStatus = .ok) -> HTTPResponse {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "text/plain; charset=utf-8")
        return HTTPResponse(status: status, headers: headers, body: Data(string.utf8))
    }

    public static func html(_ string: String, status: HTTPStatus = .ok) -> HTTPResponse {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "text/html; charset=utf-8")
        return HTTPResponse(status: status, headers: headers, body: Data(string.utf8))
    }

    public static func json<T: Encodable>(_ value: T, status: HTTPStatus = .ok) throws -> HTTPResponse {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        return HTTPResponse(status: status, headers: headers, body: data)
    }

    public static func notFound(_ message: String = "Not Found") -> HTTPResponse {
        text(message, status: .notFound)
    }

    public func serialize() -> Data {
        var head = "HTTP/1.1 \(status.code) \(status.reason)\r\n"
        var headers = self.headers
        if headers.first(name: "Content-Length") == nil {
            headers.replaceOrAdd(name: "Content-Length", value: String(body.count))
        }
        if headers.first(name: "Connection") == nil {
            headers.replaceOrAdd(name: "Connection", value: "close")
        }
        for (name, value) in headers.pairs {
            head += "\(name): \(value)\r\n"
        }
        head += "\r\n"
        var data = Data(head.utf8)
        data.append(body)
        return data
    }
}
