import Vapor
import Foundation
import TabularData

/// Reads `sandbox/Resources/Datasets/datasets.json` at startup, parses each
/// referenced CSV with TabularData, and logs one `[Datasets]` line per
/// successfully loaded dataset including the parse duration in milliseconds.
///
/// On parse failure the dataset is reported as a warning instead of a
/// success line. A missing or malformed manifest is silent — the sandbox-side
/// `Dataset.iris` accessor has its own load path and surfaces its own errors.
enum DatasetLoader {

    static func logBundledDatasets(app: Application) {
        let workingDir = app.directory.workingDirectory
        let datasetsDir = URL(fileURLWithPath: workingDir)
            .appendingPathComponent("sandbox", isDirectory: true)
            .appendingPathComponent("Resources", isDirectory: true)
            .appendingPathComponent("Datasets", isDirectory: true)
        let manifestURL = datasetsDir.appendingPathComponent("datasets.json")

        guard let data = try? Data(contentsOf: manifestURL) else {
            return
        }
        guard let entries = try? JSONDecoder().decode([ManifestEntry].self, from: data) else {
            return
        }

        for entry in entries {
            let csvURL = datasetsDir.appendingPathComponent(entry.csvFile)
            let start = DispatchTime.now()
            do {
                let df = try DataFrame(contentsOfCSVFile: csvURL)
                let elapsedMs = (DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
                app.logger.notice("[Datasets] \(entry.name) — \(df.rows.count) rows loaded (\(elapsedMs) ms)")
            } catch {
                app.logger.warning("[Datasets] \(entry.name) — could not parse \(entry.csvFile) (\(error))")
            }
        }
    }

    private struct ManifestEntry: Decodable {
        let name: String
        let kind: String
        let description: String
        let csvFile: String
    }
}
