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
//
// Quiver ships the retrieval scaffolding as three pieces that snap
// together. A `Chunker` decides where a document is cut. An `Embedder`
// turns text into a vector. An `EmbeddingIndex` holds the embedded
// corpus and ranks a query against it. We write the first two — where to
// cut and where vectors come from are our decisions — and the index does
// the embed-once, rank-each-query work for us.

guard let glove = Dataset.glove50d else {
    exit(0)
}

// An embedding source. Embed text by averaging the GloVe vectors of its
// tokens; return nil when no token is recognized, the signal the rest of
// the retrieval surface relies on. A sentence model would conform the
// same way — one method, text in, vector out — and nothing downstream
// would change.
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

// A chunking strategy. Split on blank lines into paragraph fragments;
// asChunks() trims, drops the empties, and numbers what remains, so each
// fragment carries the position it was cut at and stays attributable.
// Where to cut is a developer decision — sentences or sections conform
// the same way.
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

// Build the index: embed each chunk once, at ingest, storing the chunk
// beside its vector. In a real system the index is Codable, so these
// vectors persist to disk and load once per launch rather than being
// recomputed.
var index = EmbeddingIndex<Chunk>(embedder: GloVeEmbedder(table: glove))
for chunk in passage.chunked(using: ParagraphChunker()) {
    index.add(chunk.text, label: chunk)
}

// Retrieve the top fragment for a question. Only the query is embedded at
// search time; the chunks were embedded once at ingest. The index ranks
// and exposes its math — it does not judge relevance. Whether the top hit
// is good enough to act on is ours to decide.
func retrieve(_ question: String) {
    let result = index.retrieve(question, k: 1)
    if let top = result.hits.first {
        print("Q: \(question)")
        print("  -> chunk \(top.label.index)  (\(String(format: "%.3f", top.score)))  \(top.label.text)")
        print()
    }
}

// Change the question and the fragment that answers it rises to the top.
// The chunks never move — the question moves relative to them.
retrieve("how long should the dough rise")
retrieve("what temperature to bake at")
