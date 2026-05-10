import Foundation
import Network
import Dispatch

final class Server: @unchecked Sendable {
    private let host: String
    private let port: Int
    private let router: Router
    private let queue = DispatchQueue(label: "pelican.server", qos: .userInitiated)
    private var listener: NWListener?

    init(host: String, port: Int, router: Router) {
        self.host = host
        self.port = port
        self.router = router
    }

    func run() async throws {
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        if let inetOptions = parameters.defaultProtocolStack.internetProtocol as? NWProtocolIP.Options {
            inetOptions.version = .v4
        }

        guard let nwPort = NWEndpoint.Port(rawValue: UInt16(port)) else {
            throw ServerError.invalidPort(port)
        }

        let listener = try NWListener(using: parameters, on: nwPort)
        self.listener = listener

        listener.newConnectionHandler = { [weak self] connection in
            self?.handle(connection: connection)
        }

        let ready = AsyncStream<Void> { continuation in
            listener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    continuation.yield(())
                case .failed(let error):
                    print("Pelican listener failed: \(error)")
                    continuation.finish()
                case .cancelled:
                    continuation.finish()
                default:
                    break
                }
            }
        }

        listener.start(queue: queue)

        for await _ in ready {
            print("Pelican listening on http://\(host):\(port)")
            break
        }

        try await Task.sleep(nanoseconds: .max)
    }

    func shutdown() {
        listener?.cancel()
        listener = nil
    }

    private func handle(connection: NWConnection) {
        connection.start(queue: queue)
        receiveLoop(connection: connection, buffer: Data())
    }

    private func receiveLoop(connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else { return }

            if let error {
                print("Pelican receive error: \(error)")
                connection.cancel()
                return
            }

            var buffer = buffer
            if let data, !data.isEmpty {
                buffer.append(data)
            }

            do {
                let result = try HTTPParser.parse(buffer: buffer)
                switch result {
                case .needMoreData:
                    if isComplete {
                        connection.cancel()
                    } else {
                        self.receiveLoop(connection: connection, buffer: buffer)
                    }
                case .complete(let request, _):
                    Task {
                        let response = await self.dispatch(request: request)
                        self.send(response: response, on: connection)
                    }
                }
            } catch {
                let response = HTTPResponse.text("Bad Request: \(error)", status: .badRequest)
                self.send(response: response, on: connection)
            }
        }
    }

    private func dispatch(request: HTTPRequest) async -> HTTPResponse {
        guard let match = router.match(method: request.method, path: request.path) else {
            return .notFound()
        }
        var enriched = request
        enriched.pathParameters = match.parameters
        do {
            return try await match.handler(enriched)
        } catch {
            return HTTPResponse.text("Internal Server Error: \(error)", status: .internalServerError)
        }
    }

    private func send(response: HTTPResponse, on connection: NWConnection) {
        let data = response.serialize()
        connection.send(content: data, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }
}

enum ServerError: Error {
    case invalidPort(Int)
}
