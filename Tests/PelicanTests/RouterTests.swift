import XCTest
@testable import Pelican

final class RouterTests: XCTestCase {

    func testMatchesLiteralPath() async throws {
        let router = Router()
        router.register(method: .GET, path: "/api/status") { _ in
            HTTPResponse.text("ok")
        }
        let match = router.match(method: .GET, path: "/api/status")
        XCTAssertNotNil(match)
        XCTAssertTrue(match!.parameters.isEmpty)
    }

    func testMissesOnMethodMismatch() {
        let router = Router()
        router.register(method: .GET, path: "/x") { _ in HTTPResponse() }
        XCTAssertNil(router.match(method: .POST, path: "/x"))
    }

    func testMissesOnPathMismatch() {
        let router = Router()
        router.register(method: .GET, path: "/a") { _ in HTTPResponse() }
        XCTAssertNil(router.match(method: .GET, path: "/b"))
    }

    func testCapturesPathParameter() {
        let router = Router()
        router.register(method: .GET, path: "/api/examples/:name") { _ in HTTPResponse() }
        let match = router.match(method: .GET, path: "/api/examples/hello")
        XCTAssertEqual(match?.parameters["name"], "hello")
    }

    func testCapturesMultipleParameters() {
        let router = Router()
        router.register(method: .GET, path: "/users/:userID/posts/:postID") { _ in HTTPResponse() }
        let match = router.match(method: .GET, path: "/users/42/posts/7")
        XCTAssertEqual(match?.parameters["userID"], "42")
        XCTAssertEqual(match?.parameters["postID"], "7")
    }

    func testRejectsTrailingSegmentMismatch() {
        let router = Router()
        router.register(method: .GET, path: "/api/examples/:name") { _ in HTTPResponse() }
        XCTAssertNil(router.match(method: .GET, path: "/api/examples/hello/extra"))
    }
}
