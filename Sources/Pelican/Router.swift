import Foundation

public typealias RouteHandler = @Sendable (HTTPRequest) async throws -> HTTPResponse

struct Route {
    let method: HTTPMethod
    let segments: [PathSegment]
    let handler: RouteHandler
}

enum PathSegment: Equatable {
    case literal(String)
    case parameter(String)
    case wildcard

    static func parse(_ path: String) -> [PathSegment] {
        path.split(separator: "/", omittingEmptySubsequences: true).map { piece in
            if piece.hasPrefix(":") {
                return .parameter(String(piece.dropFirst()))
            }
            if piece == "*" {
                return .wildcard
            }
            return .literal(String(piece))
        }
    }
}

public final class Router: @unchecked Sendable {
    private var routes: [Route] = []

    public init() {}

    public func register(method: HTTPMethod, path: String, handler: @escaping RouteHandler) {
        let segments = PathSegment.parse(path)
        routes.append(Route(method: method, segments: segments, handler: handler))
    }

    public func match(method: HTTPMethod, path: String) -> (handler: RouteHandler, parameters: [String: String])? {
        let requestSegments = path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)

        for route in routes where route.method == method {
            if let params = matchSegments(route: route.segments, request: requestSegments) {
                return (route.handler, params)
            }
        }
        return nil
    }

    private func matchSegments(route: [PathSegment], request: [String]) -> [String: String]? {
        guard route.count == request.count else { return nil }
        var parameters: [String: String] = [:]
        for (segment, value) in zip(route, request) {
            switch segment {
            case .literal(let expected):
                guard expected == value else { return nil }
            case .parameter(let name):
                parameters[name] = value
            case .wildcard:
                continue
            }
        }
        return parameters
    }
}
