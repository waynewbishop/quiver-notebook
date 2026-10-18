import XCTest
import Foundation
import Quiver
@testable import Runner

final class TabularDatasetEditingTests: XCTestCase {

    /// Builds a small run log with one categorical column for each test.
    private func makeRuns() -> TabularDataset {
        let panel = Panel([
            ("distanceKm", [5.0, 3.0, 10.0]),
            ("minutes", [27.0, 16.5, 58.0]),
            ("hr", [142.0, 138.0, 151.0]),
            ("activity", [1.0, 2.0, 1.0])
        ])
        return TabularDataset(
            name: "runs",
            description: "Test runs",
            categoricalMappings: ["activity": ["idle", "run", "walk"]],
            panel: panel
        )
    }

    // MARK: - Column subscript

    func testSubscriptReadsColumn() {
        let runs = makeRuns()
        XCTAssertEqual(runs["hr"], [142.0, 138.0, 151.0])
    }

    func testSubscriptCreatesColumnAtEnd() {
        var runs = makeRuns()
        runs["pace"] = runs["minutes"].divide(runs["distanceKm"])
        XCTAssertEqual(runs.columnNames, ["distanceKm", "minutes", "hr", "activity", "pace"])
        XCTAssertEqual(runs["pace"], [5.4, 5.5, 5.8])
    }

    func testSubscriptReplacesColumnInPlace() {
        var runs = makeRuns()
        runs["hr"] = [140.0, 135.0, 150.0]
        XCTAssertEqual(runs.columnNames, ["distanceKm", "minutes", "hr", "activity"])
        XCTAssertEqual(runs["hr"], [140.0, 135.0, 150.0])
    }

    func testSubscriptReplacingCategoricalColumnDropsMapping() {
        var runs = makeRuns()
        runs["activity"] = [0.0, 0.0, 0.0]
        XCTAssertNil(runs.categoricalMappings["activity"])
    }

    func testSubscriptUnknownColumnProblem() {
        let runs = makeRuns()
        let problem = runs.columnProblem("pace", in: "dataset[\"pace\"]")
        XCTAssertEqual(problem, "dataset[\"pace\"]: no column named 'pace'. Columns are: distanceKm, minutes, hr, activity.")
        XCTAssertNil(runs.columnProblem("hr", in: "dataset[\"hr\"]"))
    }

    func testSubscriptWrongLengthProblem() {
        let runs = makeRuns()
        let problem = runs.lengthProblem(2, in: "dataset[\"pace\"] = ...")
        XCTAssertEqual(problem, "dataset[\"pace\"] = ...: the new column has 2 values but the dataset has 3 rows.")
        XCTAssertNil(runs.lengthProblem(3, in: "dataset[\"pace\"] = ..."))
    }

    // MARK: - Rows

    func testRowAtReturnsEveryColumn() {
        let runs = makeRuns()
        XCTAssertEqual(runs.row(at: 1), ["distanceKm": 3.0, "minutes": 16.5, "hr": 138.0, "activity": 2.0])
    }

    func testRowIndexProblem() {
        let runs = makeRuns()
        XCTAssertEqual(runs.rowIndexProblem(3, in: "row(at:)"), "row(at:): row 3 is out of range. Valid rows are 0 through 2.")
        XCTAssertNotNil(runs.rowIndexProblem(-1, in: "row(at:)"))
        XCTAssertNil(runs.rowIndexProblem(2, in: "row(at:)"))
    }

    func testAppendRowFillsOmittedColumnsWithNaN() {
        var runs = makeRuns()
        runs.appendRow(["distanceKm": 4.0, "hr": 139.0])
        XCTAssertEqual(runs.count, 4)
        let added = runs.row(at: 3)
        XCTAssertEqual(added["distanceKm"], 4.0)
        XCTAssertEqual(added["hr"], 139.0)
        XCTAssertEqual(added["minutes"]?.isNaN, true)
        XCTAssertEqual(added["activity"]?.isNaN, true)
    }

    func testAppendRowUnknownColumnProblem() {
        let runs = makeRuns()
        let problem = runs.unknownColumnsProblem(["hr": 139.0, "pace": 5.4, "cadence": 170.0], in: "appendRow(_:)")
        XCTAssertEqual(problem, "appendRow(_:): no column named 'cadence', 'pace'. Columns are: distanceKm, minutes, hr, activity.")
        XCTAssertNil(runs.unknownColumnsProblem(["hr": 139.0], in: "appendRow(_:)"))
    }

    func testUpdateRowChangesOnlyNamedColumns() {
        var runs = makeRuns()
        runs.updateRow(at: 0, with: ["hr": 151.0])
        XCTAssertEqual(runs["hr"], [151.0, 138.0, 151.0])
        XCTAssertEqual(runs["minutes"], [27.0, 16.5, 58.0])
    }

    func testRemoveRowShiftsLaterRows() {
        var runs = makeRuns()
        runs.removeRow(at: 1)
        XCTAssertEqual(runs.count, 2)
        XCTAssertEqual(runs["distanceKm"], [5.0, 10.0])
        XCTAssertEqual(runs["activity"], [1.0, 1.0])
    }

    func testRemoveRowsWhereRemovesMaskedRowsTogether() {
        var runs = makeRuns()
        runs.removeRows(where: [true, false, true])
        XCTAssertEqual(runs.count, 1)
        XCTAssertEqual(runs.row(at: 0), ["distanceKm": 3.0, "minutes": 16.5, "hr": 138.0, "activity": 2.0])
    }

    func testRemoveRowsWithOutlierMask() {
        var runs = makeRuns()
        let mask = runs["hr"].isGreaterThan(150.0)
        runs.removeRows(where: mask)
        XCTAssertEqual(runs["hr"], [142.0, 138.0])
    }

    func testMaskProblems() {
        let runs = makeRuns()
        XCTAssertEqual(runs.maskProblem([true, false]), "removeRows(where:): the mask has 2 values but the dataset has 3 rows.")
        XCTAssertEqual(runs.maskProblem([true, true, true]), "removeRows(where:): the mask would remove every row. A dataset needs at least one row.")
        XCTAssertNil(runs.maskProblem([false, false, false]))
    }

    // MARK: - Columns

    func testRenameColumnKeepsPositionAndValues() {
        var runs = makeRuns()
        runs.renameColumn("hr", to: "heartRate")
        XCTAssertEqual(runs.columnNames, ["distanceKm", "minutes", "heartRate", "activity"])
        XCTAssertEqual(runs["heartRate"], [142.0, 138.0, 151.0])
    }

    func testRenameColumnMovesCategoricalMapping() {
        var runs = makeRuns()
        runs.renameColumn("activity", to: "mode")
        XCTAssertNil(runs.categoricalMappings["activity"])
        XCTAssertEqual(runs.categoricalMappings["mode"], ["idle", "run", "walk"])
    }

    func testRenameProblem() {
        let runs = makeRuns()
        XCTAssertEqual(runs.renameProblem("hr", to: "minutes"), "renameColumn(_:to:): a column named 'minutes' already exists.")
        XCTAssertNil(runs.renameProblem("hr", to: "heartRate"))
        XCTAssertNil(runs.renameProblem("hr", to: "hr"))
    }

    func testRemoveColumnDropsColumnAndMapping() {
        var runs = makeRuns()
        runs.removeColumn("activity")
        XCTAssertEqual(runs.columnNames, ["distanceKm", "minutes", "hr"])
        XCTAssertTrue(runs.categoricalMappings.isEmpty)
    }

    func testLastColumnProblem() {
        var runs = makeRuns()
        XCTAssertNil(runs.lastColumnProblem("hr"))
        runs.removeColumn("distanceKm")
        runs.removeColumn("minutes")
        runs.removeColumn("activity")
        XCTAssertEqual(runs.lastColumnProblem("hr"), "removeColumn(_:): 'hr' is the only column. A dataset needs at least one column.")
    }

    // MARK: - Snapshots and summaries

    func testEditsDoNotChangeEarlierPanelOrCopies() {
        var runs = makeRuns()
        let panel = runs.toPanel()
        let copy = runs
        runs.removeColumn("minutes")
        XCTAssertEqual(panel.columnNames.count, 4)
        XCTAssertEqual(copy.columnNames.count, 4)
        XCTAssertEqual(runs.toPanel().columnNames.count, 3)
    }

    func testDescribeMatchesPanelDescribe() {
        let runs = makeRuns()
        XCTAssertEqual(runs.describe(), runs.toPanel().describe())
    }

    // MARK: - Loading

    func testLoadedCSVSupportsEditing() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let csv = """
        distanceKm,minutes,hr,activity
        5.0,27.0,142,run
        3.0,16.5,138,walk
        10.0,58.0,151,run
        """
        let url = directory.appendingPathComponent("class-runs.csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)

        guard var runs = Dataset.load(path: url.path) else {
            return XCTFail("Expected the CSV to load")
        }
        XCTAssertEqual(runs.name, "class-runs")
        XCTAssertEqual(runs.categoricalMappings["activity"], ["run", "walk"])

        runs["pace"] = runs["minutes"].divide(runs["distanceKm"])
        runs.renameColumn("hr", to: "heartRate")
        runs.appendRow(["distanceKm": 3.0, "minutes": 16.2, "heartRate": 139.0, "activity": 1.0, "pace": 5.4])
        runs.removeRows(where: runs["heartRate"].isGreaterThan(150.0))
        runs.removeColumn("minutes")

        XCTAssertEqual(runs.columnNames, ["distanceKm", "heartRate", "activity", "pace"])
        XCTAssertEqual(runs["heartRate"], [142.0, 138.0, 139.0])
        XCTAssertEqual(runs.toPanel().shape.rows, 3)
    }
}
