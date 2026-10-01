import XCTest
import Network
@testable import Pelican

final class ServerTests: XCTestCase {

    func testListenerBindsToLoopbackOnly() throws {
        let parameters = try Server.listenerParameters(host: "127.0.0.1", port: 8080)
        guard case let .hostPort(host, port)? = parameters.requiredLocalEndpoint else {
            return XCTFail("Listener has no required local endpoint, so it accepts connections on every interface.")
        }
        XCTAssertEqual(host, NWEndpoint.Host("127.0.0.1"))
        XCTAssertEqual(port, NWEndpoint.Port(rawValue: 8080))
    }

    func testRejectsPortOutOfRange() {
        XCTAssertThrowsError(try Server.listenerParameters(host: "127.0.0.1", port: 70_000))
        XCTAssertThrowsError(try Server.listenerParameters(host: "127.0.0.1", port: -1))
    }
}
