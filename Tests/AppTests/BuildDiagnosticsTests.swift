import XCTest
@testable import App

final class BuildDiagnosticsTests: XCTestCase {

    private let main = "/Users/student/quiver-notebook/sandbox/Sources/Runner/main.swift"
    private let esc = "\u{1B}"

    /// Cleans raw output using the Runner's real wrapper offset.
    private func clean(_ raw: String, userLines: Int) -> String {
        BuildDiagnostics.clean(raw, wrapperLineCount: Runner.wrapperLineCount, userLineCount: userLines)
    }

    func testWrapperPlacesUserCodeAfterWrapperLines() {
        let lines = Runner.wrap(userCode: "print(1)").components(separatedBy: "\n")
        XCTAssertEqual(lines[Runner.wrapperLineCount], "print(1)")
    }

    func testRenumbersErrorAndExcerptToEditorLines() {
        let raw = """
        Building for debugging...
        [2 / 6] Runner-product
        error: SwiftCompile normal arm64 \(main) failed with a nonzero exit code. Command line:     cd /Users/student/quiver-notebook
            builtin-SwiftPerFileCompile main.swift
        \(main):8:20: \(esc)[1;31merror: \(esc)[1;39mvalue of type 'String' has no member 'character'\(esc)[0;0m
         \(esc)[0;36m6 |\(esc)[0;0m print(something)
         \(esc)[0;36m7 |\(esc)[0;0m
         \(esc)[0;36m8 |\(esc)[0;0m for c in something.character {
           \(esc)[0;36m|\(esc)[0;0m                    `- error: value of type 'String' has no member 'character'
         \(esc)[0;36m9 |\(esc)[0;0m     print(c)
        \(esc)[0;36m10 |\(esc)[0;0m }
        Failed frontend command:
        /Applications/Xcode.app/usr/bin/swift-frontend -frontend -c \(main)
        error: Build failed
        """
        let expected = """
        line 4:20: error: value of type 'String' has no member 'character'
        2 | print(something)
        3 |
        4 | for c in something.character {
          |                    `- error: value of type 'String' has no member 'character'
        5 |     print(c)
        6 | }
        """
        XCTAssertEqual(clean(raw, userLines: 6), expected)
    }

    func testDropsWrapperRowsFromExcerpt() {
        let raw = """
        \(main):5:14: error: cannot convert value of type 'String' to specified type 'Int'
        3 | setvbuf(stdout, nil, _IOLBF, 0)
        4 | // --- user code begins ---
        5 | let a: Int = "hello"
          |              `- error: cannot convert value of type 'String' to specified type 'Int'
        6 |
        7 | // --- user code ends ---
        """
        let expected = """
        line 1:14: error: cannot convert value of type 'String' to specified type 'Int'
        1 | let a: Int = "hello"
          |              `- error: cannot convert value of type 'String' to specified type 'Int'
        """
        XCTAssertEqual(clean(raw, userLines: 1), expected)
    }

    func testCollapsesDuplicateDiagnosticsAndKeepsNotes() {
        let block = """
        \(main):6:16: error: missing argument for parameter 'by' in call
        5 | func scale(_ x: Double, by factor: Double) -> Double { x * factor }
          |      `- note: 'scale(_:by:)' declared here
        6 | print(scale(2.0))
          |                `- error: missing argument for parameter 'by' in call
        """
        let raw = block + "\nFailed frontend command:\n" + block + "\nerror: Build failed"
        let expected = """
        line 2:16: error: missing argument for parameter 'by' in call
        1 | func scale(_ x: Double, by factor: Double) -> Double { x * factor }
          |      `- note: 'scale(_:by:)' declared here
        2 | print(scale(2.0))
          |                `- error: missing argument for parameter 'by' in call
        """
        XCTAssertEqual(clean(raw, userLines: 2), expected)
    }

    func testRepadsGutterWhenRenumberingShrinksIt() {
        let raw = """
        \(main):13:23: error: cannot convert value of type 'Int' to specified type 'String'
        11 | let g = 7
        12 | print(a + b)
        13 | let total: String = a + b
           |                       `- error: cannot convert value of type 'Int' to specified type 'String'
        """
        let expected = """
        line 9:23: error: cannot convert value of type 'Int' to specified type 'String'
        7 | let g = 7
        8 | print(a + b)
        9 | let total: String = a + b
          |                       `- error: cannot convert value of type 'Int' to specified type 'String'
        """
        XCTAssertEqual(clean(raw, userLines: 9), expected)
    }

    func testSeparatesMultipleDiagnostics() {
        let raw = """
        \(main):5:14: error: first problem
        5 | let a: Int = "hello"
          |              `- error: first problem

        \(main):7:9: error: second problem
        7 | print(v.meen())
          |         `- error: second problem
        """
        let output = clean(raw, userLines: 3)
        XCTAssertTrue(output.hasPrefix("line 1:14: error: first problem"))
        XCTAssertTrue(output.contains("\n\nline 3:9: error: second problem"))
    }

    func testLinkerErrorFallsBackWithoutCommandDump() {
        let raw = """
        Building for debugging...
        [2\u{2009}/\u{2009}8] Quiver
        Undefined symbols for architecture arm64:
          "_quiver_does_not_exist", referenced from:
              _main in main.o
        ld: symbol(s) not found for architecture arm64
        /Users/student/quiver-notebook/sandbox/Package.swift: Runner-product: clang: error: linker command failed with exit code 1 (use -v to see invocation)
        error: Ld /Users/student/quiver-notebook/sandbox/.build/out/Products/Debug/Runner normal failed with a nonzero exit code. Command line:     cd /Users/student/quiver-notebook/sandbox
            /Applications/Xcode.app/usr/bin/swiftc -emit-executable -o Runner
        error: Build failed
        """
        let expected = """
        Undefined symbols for architecture arm64:
          "_quiver_does_not_exist", referenced from:
              _main in main.o
        ld: symbol(s) not found for architecture arm64
        clang: error: linker command failed with exit code 1 (use -v to see invocation)
        error: Build failed
        """
        XCTAssertEqual(clean(raw, userLines: 2), expected)
    }

    func testNeverReturnsEmptyOutput() {
        let raw = "Building for debugging...\n[2 / 6] Runner-product"
        XCTAssertFalse(clean(raw, userLines: 1).isEmpty)
    }
}
