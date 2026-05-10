import XCTest
@testable import Pelican

final class HTTPParserTests: XCTestCase {

    func testParsesSimpleGET() throws {
        let raw = "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"
        let result = try HTTPParser.parse(buffer: Data(raw.utf8))
        guard case .complete(let request, let consumed) = result else {
            return XCTFail("expected complete result")
        }
        XCTAssertEqual(request.method, .GET)
        XCTAssertEqual(request.path, "/")
        XCTAssertEqual(request.headers.first(name: "Host"), "localhost")
        XCTAssertEqual(consumed, raw.utf8.count)
    }

    func testParsesPOSTWithJSONBody() throws {
        let body = #"{"code":"print(\"hi\")"}"#
        let raw = "POST /api/run HTTP/1.1\r\nHost: localhost\r\nContent-Type: application/json\r\nContent-Length: \(body.utf8.count)\r\n\r\n\(body)"
        let result = try HTTPParser.parse(buffer: Data(raw.utf8))
        guard case .complete(let request, _) = result else {
            return XCTFail("expected complete result")
        }
        XCTAssertEqual(request.method, .POST)
        XCTAssertEqual(request.path, "/api/run")
        XCTAssertEqual(String(data: request.body, encoding: .utf8), body)
    }

    func testParsesQueryString() throws {
        let raw = "GET /search?q=hello&limit=10 HTTP/1.1\r\nHost: localhost\r\n\r\n"
        let result = try HTTPParser.parse(buffer: Data(raw.utf8))
        guard case .complete(let request, _) = result else {
            return XCTFail("expected complete result")
        }
        XCTAssertEqual(request.path, "/search")
        XCTAssertEqual(request.query["q"], "hello")
        XCTAssertEqual(request.query["limit"], "10")
    }

    func testReturnsNeedMoreDataWhenHeadersIncomplete() throws {
        let raw = "GET / HTTP/1.1\r\nHost: localhost\r\n"
        let result = try HTTPParser.parse(buffer: Data(raw.utf8))
        guard case .needMoreData = result else {
            return XCTFail("expected needMoreData")
        }
    }

    func testReturnsNeedMoreDataWhenBodyIncomplete() throws {
        let raw = "POST /x HTTP/1.1\r\nContent-Length: 100\r\n\r\nshort"
        let result = try HTTPParser.parse(buffer: Data(raw.utf8))
        guard case .needMoreData = result else {
            return XCTFail("expected needMoreData")
        }
    }

    func testRejectsUnsupportedMethod() {
        let raw = "BREW / HTTP/1.1\r\n\r\n"
        XCTAssertThrowsError(try HTTPParser.parse(buffer: Data(raw.utf8))) { error in
            guard case HTTPParserError.unsupportedMethod(let token) = error else {
                return XCTFail("expected unsupportedMethod")
            }
            XCTAssertEqual(token, "BREW")
        }
    }

    func testRejectsBodyOverLimit() {
        let raw = "POST /x HTTP/1.1\r\nContent-Length: 99999\r\n\r\n"
        XCTAssertThrowsError(try HTTPParser.parse(buffer: Data(raw.utf8), bodyLimit: 1024)) { error in
            guard case HTTPParserError.bodyTooLarge = error else {
                return XCTFail("expected bodyTooLarge")
            }
        }
    }

    func testHeaderLookupIsCaseInsensitive() throws {
        let raw = "GET / HTTP/1.1\r\ncontent-type: text/plain\r\n\r\n"
        let result = try HTTPParser.parse(buffer: Data(raw.utf8))
        guard case .complete(let request, _) = result else {
            return XCTFail("expected complete result")
        }
        XCTAssertEqual(request.headers.first(name: "Content-Type"), "text/plain")
    }
}
