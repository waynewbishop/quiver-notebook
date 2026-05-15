// Title: Explore Word Embeddings
//
// Word embeddings turn vocabulary into geometry. Each word becomes a
// point in a high-dimensional space arranged so that words used in
// similar contexts land near each other. Once words are vectors, the
// usual vector tools — cosine similarity, addition, subtraction —
// answer questions about meaning.
//
// Dataset.glove50d ships the 5,000 most-frequent English words from
// Stanford's GloVe corpus, each a 50-dimensional vector, bundled with
// the Notebook. No download, no setup. The same Quiver primitives that
// score user-similarity in a recommender or align time-series readings
// from a watch sensor are the ones doing the work below.

guard let glove = Dataset.glove50d else {
    exit(0)
}

// Peek at the first three words by frequency rank.
print(glove.head(n: 3))
print()

// Look up a single word's vector.
if let kingVector = glove["king"] {
    print("king is a \(kingVector.count)-dimensional vector")
    print("first three components:", kingVector.prefix(3).map { String(format: "%.4f", $0) })
}
print()

// Nearest neighbours by cosine similarity. The query word is excluded
// from results, so glove.nearest(to: "paris") returns the closest
// other words in the vocabulary.
print("nearest to paris:")
for hit in glove.nearest(to: "paris", k: 5) {
    print("  \(hit.rank). \(hit.word)  \(String(format: "%.4f", hit.score))")
}
print()

// The classic analogy: king − man + woman ≈ ? The target vector lives
// somewhere between male royalty and female non-royalty, and the closest
// vocabulary entry typically lands on female royalty.
print("king − man + woman ≈")
for hit in glove.analogy("king", "man", "woman", k: 1) {
    print("  \(hit.rank). \(hit.word)  \(String(format: "%.4f", hit.score))")
}
