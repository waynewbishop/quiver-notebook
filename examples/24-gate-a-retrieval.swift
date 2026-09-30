// Title: Gate a Retrieval
//
// Example 22 retrieves the best fragment for a question. But retrieval
// always returns something — ranking only asks which chunk is closest,
// never whether the closest one is actually close. Ask this corpus about
// phone batteries and a chunk about dough still comes back first. Handing
// that weak context to a language model invites a confident wrong answer;
// the honest move is to detect the miss and say "I don't know."
//
// That decision is the caller's, and `RetrievalResult` exposes the math
// to make it: the full score field with its mean and standard deviation,
// the top score, and the top hit's z-score. `isAboveGate(floor:outlierZ:)`
// composes two checks — the top hit is good on its own terms, or it
// stands clearly above the rest of the field. The thresholds have no
// defaults on purpose: the right values depend on the embedder and the
// corpus, so Quiver supplies the composition and never the cutoff.
//
// Both honesty notes below are visible in the numbers. Mean-pooled GloVe
// vectors score generously — common words pull every sentence toward a
// shared direction, so even an off-topic question lands above 0.8 — which
// is why this caller sets the floor at 0.90 rather than something low.
// And with only three chunks, a sample z-score can never exceed
// (n − 1) / √n ≈ 1.15, so the absolute floor is the live path here; the
// z ≥ 3.0 outlier check earns its keep on a corpus of a dozen chunks or
// more, where one hit standing far above the field is a real signal.

guard let glove = Dataset.glove50d else {
    exit(0)
}

// The same embedder as example 22: average the GloVe vectors of the
// tokens, and return nil when no token is recognized.
struct GloVeEmbedder: Embedder {
    let table: EmbeddingsDataset

    func embed(_ text: String) -> [Double]? {
        var wordVectors: [[Double]] = []
        for token in text.tokenize() {
            if let vector = table[token] {
                wordVectors.append(vector)
            }
        }
        return wordVectors.meanVector()
    }
}

// The same chunking strategy as example 22: split on blank lines,
// letting asChunks() trim, drop empties, and number what remains.
struct ParagraphChunker: Chunker {
    func chunk(_ text: String) -> [Chunk] {
        text.components(separatedBy: "\n\n").asChunks()
    }
}

let passage = """
Let the dough rise slowly. A slow proof develops flavor as the yeast works.

Knead the dough until smooth, then shape it.

Bake in a hot oven. The heat sets the crust.
"""

// Embed each chunk once, at ingest.
var index = EmbeddingIndex<Chunk>(embedder: GloVeEmbedder(table: glove))
for chunk in passage.chunked(using: ParagraphChunker()) {
    index.add(chunk.text, label: chunk)
}

// Retrieve, read the score field, and gate. The 0.90 floor and 3.0
// outlier bar are this caller's policy, calibrated to this embedder and
// this corpus — another embedder would earn different numbers.
func gate(_ question: String) {
    let result = index.retrieve(question, k: 1)
    let meanScore = String(format: "%.4f", result.mean)
    let spread = String(format: "%.4f", result.standardDeviation)
    let topScore = String(format: "%.4f", result.topScore)
    let topZ = String(format: "%.2f", result.topZScore)
    let isRelevant = result.isAboveGate(floor: 0.90, outlierZ: 3.0)
    print("Q: \(question)")
    print("  field: mean \(meanScore), spread \(spread)")
    print("  top hit: \(topScore), \(topZ) standard deviations above the field")
    if isRelevant {
        print("  gate: passed — hand the top chunk to the model")
    } else {
        print("  gate: failed — answer honestly that the document does not cover this")
    }
    print()
}

// A question the passage answers: the oven chunk clears the floor.
gate("what temperature to bake at")
//   field: mean 0.8694, spread 0.0361
//   top hit: 0.9111, 1.15 standard deviations above the field
//   gate: passed

// An off-topic question: a chunk still ranks first, but it clears
// neither bar, so the gate turns it away.
gate("how do I charge my phone battery")
//   field: mean 0.7596, spread 0.0666
//   top hit: 0.8145, 0.82 standard deviations above the field
//   gate: failed
