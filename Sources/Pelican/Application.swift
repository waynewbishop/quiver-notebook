import Foundation

public final class Application: @unchecked Sendable {
    public let router: Router
    public var host: String
    public var port: Int

    private var server: Server?

    public init(host: String = "127.0.0.1", port: Int = 8080) {
        self.host = host
        self.port = port
        self.router = Router()
    }

    public func get(_ path: String, use handler: @escaping RouteHandler) {
        router.register(method: .GET, path: path, handler: handler)
    }

    public func post(_ path: String, use handler: @escaping RouteHandler) {
        router.register(method: .POST, path: path, handler: handler)
    }

    public func put(_ path: String, use handler: @escaping RouteHandler) {
        router.register(method: .PUT, path: path, handler: handler)
    }

    public func delete(_ path: String, use handler: @escaping RouteHandler) {
        router.register(method: .DELETE, path: path, handler: handler)
    }

    public func run() async throws {
        let server = Server(host: host, port: port, router: router)
        self.server = server
        try await server.run()
    }

    public func shutdown() {
        server?.shutdown()
    }
}
