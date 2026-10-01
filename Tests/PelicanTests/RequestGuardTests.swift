import XCTest
@testable import Pelican

final class RequestGuardTests: XCTestCase {

    private let token = "abc123"

    /// Builds a request with the given method and headers.
    private func request(_ method: HTTPMethod, _ headers: [(String, String)]) -> HTTPRequest {
        HTTPRequest(method: method, path: "/api/run", headers: HTTPHeaders(headers))
    }

    /// Headers the Notebook's own editor page sends with a Run request.
    private var editorPOSTHeaders: [(String, String)] {
        [
            ("Host", "localhost:8080"),
            ("Origin", "http://localhost:8080"),
            ("Content-Type", "application/json"),
            (RequestGuard.tokenHeader, token)
        ]
    }

    func testAllowsEditorPOST() {
        let guardian = RequestGuard(port: 8080, sessionToken: token)
        XCTAssertNil(guardian.rejection(for: request(.POST, editorPOSTHeaders)))
    }

    func testAllowsSameOriginGET() {
        let guardian = RequestGuard(port: 8080, sessionToken: token)
        let get = request(.GET, [("Host", "127.0.0.1:8080")])
        XCTAssertNil(guardian.rejection(for: get))
    }

    func testAllowsJSONWithCharset() {
        let guardian = RequestGuard(port: 8080)
        let post = request(.POST, [("Host", "localhost:8080"), ("Content-Type", "application/json; charset=utf-8")])
        XCTAssertNil(guardian.rejection(for: post))
    }

    func testRejectsCrossOriginPOST() {
        let guardian = RequestGuard(port: 8080, sessionToken: token)
        var headers = editorPOSTHeaders
        headers[1] = ("Origin", "https://example.com")
        XCTAssertEqual(guardian.rejection(for: request(.POST, headers))?.status, .forbidden)
    }

    func testRejectsNullOrigin() {
        let guardian = RequestGuard(port: 8080)
        let get = request(.GET, [("Host", "localhost:8080"), ("Origin", "null")])
        XCTAssertEqual(guardian.rejection(for: get)?.status, .forbidden)
    }

    func testRejectsOriginOnDifferentPort() {
        let guardian = RequestGuard(port: 8080)
        let get = request(.GET, [("Host", "localhost:8080"), ("Origin", "http://localhost:3000")])
        XCTAssertEqual(guardian.rejection(for: get)?.status, .forbidden)
    }

    func testRejectsRebindingHost() {
        let guardian = RequestGuard(port: 8080)
        let get = request(.GET, [("Host", "attacker.example:8080")])
        XCTAssertEqual(guardian.rejection(for: get)?.status, .forbidden)
    }

    func testRejectsHostOnDifferentPort() {
        let guardian = RequestGuard(port: 8080)
        let get = request(.GET, [("Host", "localhost:9999")])
        XCTAssertEqual(guardian.rejection(for: get)?.status, .forbidden)
    }

    func testRejectsMissingHost() {
        let guardian = RequestGuard(port: 8080)
        XCTAssertEqual(guardian.rejection(for: request(.GET, []))?.status, .forbidden)
    }

    func testRejectsPlainTextPOST() {
        let guardian = RequestGuard(port: 8080, sessionToken: token)
        var headers = editorPOSTHeaders
        headers[2] = ("Content-Type", "text/plain")
        XCTAssertEqual(guardian.rejection(for: request(.POST, headers))?.status, .unsupportedMediaType)
    }

    func testRejectsPOSTWithoutContentType() {
        let guardian = RequestGuard(port: 8080)
        let post = request(.POST, [("Host", "localhost:8080")])
        XCTAssertEqual(guardian.rejection(for: post)?.status, .unsupportedMediaType)
    }

    func testRejectsMissingToken() {
        let guardian = RequestGuard(port: 8080, sessionToken: token)
        let headers = Array(editorPOSTHeaders.dropLast())
        XCTAssertEqual(guardian.rejection(for: request(.POST, headers))?.status, .forbidden)
    }

    func testRejectsWrongToken() {
        let guardian = RequestGuard(port: 8080, sessionToken: token)
        var headers = editorPOSTHeaders
        headers[3] = (RequestGuard.tokenHeader, "abc124")
        XCTAssertEqual(guardian.rejection(for: request(.POST, headers))?.status, .forbidden)
    }

    func testGETDoesNotNeedToken() {
        let guardian = RequestGuard(port: 8080, sessionToken: token)
        let get = request(.GET, [("Host", "localhost:8080"), ("Origin", "http://localhost:8080")])
        XCTAssertNil(guardian.rejection(for: get))
    }
}
