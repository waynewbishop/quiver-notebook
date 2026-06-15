// Title: Retrieval for a Question
//
// Retrieval-augmented generation answers a question from a specific
// document instead of from a model's training. The first half of that
// pipeline — the half Quiver owns — is retrieval: split the document
// into fragments, embed each one, and rank the fragments against a
// question by meaning. Only the most relevant fragments are handed to a
// language model, which generates the answer. The generation step lives
// elsewhere; everything below is the retrieval that feeds it.
//
// The match is by meaning, not by keyword. The question "what
// temperature to bake at" retrieves the sentence about a hot oven even
// though neither shares the word "temperature" — "hot," "heat," and
// "oven" sit near "temperature" in embedding space. That is the whole
// trick, and it is the same cosine-similarity math as example 20.

guard let glove = Dataset.glove50d else {
    exit(0)
}

// A chunk keeps its position so a retrieved fragment is attributable.
// Sendable lets it cross the task boundaries a background worker introduces.
struct Chunk: Sendable {
    let index: Int
    let text: String
}

// Split a passage into paragraph chunks. Where to cut is a developer
// decision — paragraphs here, but sentences or sections work the same way.
func chunked(_ passage: String) -> [Chunk] {
    let paragraphs = passage.components(separatedBy: "\n\n")
    var chunks: [Chunk] = []
    var index = 0
    for paragraph in paragraphs {
        let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { continue }
        chunks.append(Chunk(index: index, text: trimmed))
        index += 1
    }
    return chunks
}

// Embed text by averaging the GloVe vectors of its tokens. The GloVe
// table is one embedding source; a sentence model would conform the same way.
func embed(_ text: String) -> [Double]? {
    var wordVectors: [[Double]] = []
    for token in text.tokenize() {
        if let vector = glove[token] {
            wordVectors.append(vector)
        }
    }
    return wordVectors.meanVector()
}

let passage = """
Let the dough rise slowly. A slow proof develops flavor as the yeast works.

Knead the dough until smooth, then shape it.

Bake in a hot oven. The heat sets the crust.
"""

// Embed each chunk once, at ingest, keeping chunks and vectors aligned.
// In a real system these vectors persist to disk and load once per launch.
let chunks = chunked(passage)
var storedChunks: [Chunk] = []
var storedVectors: [[Double]] = []
for chunk in chunks {
    if let vector = embed(chunk.text) {
        storedChunks.append(chunk)
        storedVectors.append(vector)
    }
}

// Retrieve the top fragment for a question. Only the query is embedded at
// search time; the chunks were embedded once above.
func retrieve(_ question: String) {
    guard let queryVector = embed(question) else { return }
    let scores = storedVectors.cosineSimilarities(to: queryVector)
    let hits = scores.topIndices(k: 1, labels: storedChunks)
    if let top = hits.first {
        print("Q: \(question)")
        print("  -> chunk \(top.label.index)  (\(String(format: "%.3f", top.score)))  \(top.label.text)")
        print()
    }
}

// Change the question and the fragment that answers it rises to the top.
// The chunks never move — the question moves relative to them.
retrieve("how long should the dough rise")
retrieve("what temperature to bake at")
