import Foundation

/// Public entry point for bundled datasets.
///
/// Each dataset is exposed as `Dataset.<name>` (e.g. `Dataset.iris`).
/// Tabular accessors funnel through `DatasetLoader.loadTabular` and return
/// `TabularDataset?`. The GloVe accessor funnels through
/// `DatasetLoader.loadEmbeddings` and returns `EmbeddingsDataset?`.
/// Instructors with their own CSVs call `Dataset.load(path:)`.
extension Dataset {

    // MARK: - Bundled tabular datasets

    /// 150 rows, 5 columns. Classification. Label column: `species` (encoded
    /// alphabetically as setosa→0, versicolor→1, virginica→2).
    ///
    /// The classic introductory classification dataset — three balanced classes
    /// of 50 flowers, four numeric sepal/petal measurements. Originally
    /// collected by Edgar Anderson and published by R. A. Fisher in 1936.
    public static var iris: TabularDataset? {
        DatasetLoader.loadTabular(
            name: "iris",
            csvURL: bundledURL(for: "iris.csv"),
            description: "150 iris flowers across three species (setosa, versicolor, virginica), 50 of each. Four numeric features describe sepal and petal dimensions in centimetres. The classic introductory classification dataset, originally collected by Edgar Anderson and published by R. A. Fisher in 1936."
        )
    }

    /// 889 rows, 8 columns. Classification. Label column: `Survived` (0/1).
    ///
    /// Cleaned passenger manifest from the 1912 Titanic disaster. Good for
    /// teaching mixed numeric and categorical features, missing-value handling,
    /// and class-imbalance trade-offs against a familiar binary outcome.
    public static var titanic: TabularDataset? {
        DatasetLoader.loadTabular(
            name: "titanic",
            csvURL: bundledURL(for: "titanic.csv"),
            description: "889 passengers from the 1912 Titanic disaster with eight features per row (Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked). Cleaned from the standard Kaggle competition training set: identifier and high-cardinality string columns dropped, missing Age values median-filled, and rows with missing Embarked dropped."
        )
    }

    /// 20,640 rows, 10 columns. Regression. Target column: `median_house_value`.
    ///
    /// 1990 California census districts. The standard introductory regression
    /// dataset for teaching feature scaling, geographic features, and the gap
    /// between linear and tree-based models on real-world tabular data.
    public static var californiaHousing: TabularDataset? {
        DatasetLoader.loadTabular(
            name: "californiaHousing",
            csvURL: bundledURL(for: "california-housing.csv"),
            description: "20,640 California housing districts from the 1990 census with ten features per row, including longitude, latitude, median income, and median house value. Missing total_bedrooms values were median-filled and the ocean_proximity categorical column was recoded to snake_case tokens."
        )
    }

    /// 731 rows, 16 columns. Regression. Target column: `cnt` (total daily rides).
    ///
    /// Daily Capital Bikeshare ride counts paired with weather, calendar, and
    /// season features. A clean introduction to time-aware regression and to
    /// the seasonality patterns that make naive splits leak information.
    public static var bikeSharing: TabularDataset? {
        DatasetLoader.loadTabular(
            name: "bikeSharing",
            csvURL: bundledURL(for: "bike-sharing.csv"),
            description: "731 daily ride totals from Capital Bikeshare with 16 features per row, including weather, temperature, humidity, holiday, and day-of-week. Standard UCI Bike Sharing Dataset (day.csv) shipped in its upstream form — no missing values, no quoting issues."
        )
    }

    /// 395 rows, 33 columns. Regression (or classification on a thresholded
    /// `G3`). Target column: `G3` (final grade, 0–20).
    ///
    /// Portuguese secondary-school students with family, study, and lifestyle
    /// features alongside three sequential grade columns (G1, G2, G3). Useful
    /// for teaching feature selection and the leakage trap of training on G1
    /// and G2 to predict G3.
    public static var studentPerformance: TabularDataset? {
        DatasetLoader.loadTabular(
            name: "studentPerformance",
            csvURL: bundledURL(for: "student-performance.csv"),
            description: "395 secondary-school students from a Portuguese-language course with 33 features per row covering family background, study habits, and three sequential grade columns (G1, G2, G3). Converted from the upstream UCI semicolon-delimited format to comma-separated and stripped of inconsistent quoting; no missing values."
        )
    }

    /// 60 rows, 6 columns. Time series at 1 Hz. No label column.
    ///
    /// A synthetic 60-second tempo run for a moderately trained 70 kg runner.
    /// Heart rate drifts upward by about 6 BPM across the minute while pace
    /// and power hold steady — the decoupling that effort-classification work
    /// is built on. Pair with `simulatedRunAccel` for spectral analysis of the
    /// same run.
    public static var simulatedRun: TabularDataset? {
        DatasetLoader.loadTabular(
            name: "simulatedRun",
            csvURL: bundledURL(for: "simulated-run.csv"),
            description: "60 seconds of a synthetic tempo run for a moderately trained 70 kg runner, sampled at 1 Hz. Six columns: time (s), heartRate (BPM), pace (m/s), cadence (spm), power (W), altitude (m). Heart rate drifts +6 BPM across the minute while pace and power hold flat — the load-bearing physiological signal for multi-signal effort classification. Generated deterministically from seed 42 against a published physiological constraint spec; see CLEANING.md for the generative model."
        )
    }

    /// 3,000 rows, 2 columns. Time series at 50 Hz. No label column.
    ///
    /// Wrist accelerometer magnitude for the same 60-second tempo run exposed
    /// in `simulatedRun`. The dominant frequency is the runner's cadence
    /// (≈2.83 Hz, 170 steps per minute). Designed for spectral-analysis demos
    /// — `powerSpectralDensity`, dominant-frequency detection, and band-energy
    /// features for activity classification.
    public static var simulatedRunAccel: TabularDataset? {
        DatasetLoader.loadTabular(
            name: "simulatedRunAccel",
            csvURL: bundledURL(for: "simulated-run-accel.csv"),
            description: "Wrist accelerometer magnitude in m/s² for the same 60-second tempo run as `simulatedRun`, sampled at 50 Hz (3,000 samples). Two columns: time (s) and magnitude (m/s²). Built from a footstrike fundamental at 2.833 Hz, a two-legged-gait harmonic at 5.667 Hz, and Gaussian noise around a 1g baseline. Generated deterministically from seed 42; the two simulated-run datasets describe the same underlying event at different sample rates."
        )
    }

    // MARK: - Bundled embeddings dataset

    /// 5,000 words, 50-dimensional vectors. Lookup column: `word`.
    ///
    /// The 5,000 most-frequent English words from Stanford's GloVe 6B-token
    /// corpus, each represented as a 50-dimensional vector. Useful for
    /// teaching cosine similarity, semantic search, and word analogies
    /// (`king − man + woman ≈ queen`) without bringing in an external
    /// embeddings download.
    public static var glove50d: EmbeddingsDataset? {
        DatasetLoader.loadEmbeddings(
            name: "glove50d",
            csvURL: bundledURL(for: "glove-50d.csv"),
            description: "5,000 most-frequent English words from Stanford's GloVe 6B-token corpus, each represented as a 50-dimensional vector. Columns are `word`, `rank`, `magnitude`, `nearest`, plus `dim_01` through `dim_50`. Sliced from the upstream `glove.6B.50d.txt` by taking the first 5,000 frequency-sorted lines. Useful for teaching cosine similarity, semantic search, and word analogies in pure Swift."
        )
    }

    // MARK: - User-supplied CSV

    /// Loads a `TabularDataset` from any CSV file on disk.
    ///
    /// Tilde paths are expanded (`~/Desktop/my.csv` resolves to the user's
    /// home directory). The resulting dataset's `name` is the filename without
    /// extension, and `description` records the source filename.
    ///
    /// Returns `nil` if the CSV cannot be parsed; the underlying error is
    /// written to standard error so the cause is visible in the Notebook
    /// console. Columns whose element type is none of (numeric, `String`,
    /// `Date`) are skipped with a warning rather than failing the load.
    ///
    /// Example:
    ///
    ///     guard let dataset = Dataset.load(path: "~/Desktop/sales.csv") else {
    ///         return
    ///     }
    ///     dataset.toPanel().head()
    public static func load(path: String) -> TabularDataset? {
        let expanded = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expanded)
        let name = url.deletingPathExtension().lastPathComponent
        let description = "Loaded from \(url.lastPathComponent)"
        return DatasetLoader.loadTabular(name: name, csvURL: url, description: description)
    }

    // MARK: - Catalog

    /// Returns a human-readable listing of every bundled accessor.
    public static func catalog() -> String {
        let accessors = [
            "Dataset.iris",
            "Dataset.titanic",
            "Dataset.californiaHousing",
            "Dataset.bikeSharing",
            "Dataset.studentPerformance",
            "Dataset.simulatedRun",
            "Dataset.simulatedRunAccel",
            "Dataset.glove50d"
        ]
        return accessors.joined(separator: "\n")
    }

    // MARK: - Internal helpers

    /// Resolves a bundled CSV path relative to the sandbox's working directory.
    ///
    /// The Vapor host shells into `quiver-notebook/sandbox/` before invoking the
    /// runner, so a relative path like `Resources/Datasets/iris.csv` resolves
    /// correctly there. When running `swift run` directly inside `sandbox/`,
    /// the same path also works.
    private static func bundledURL(for csvFile: String) -> URL {
        URL(fileURLWithPath: "Resources/Datasets/\(csvFile)")
    }
}
