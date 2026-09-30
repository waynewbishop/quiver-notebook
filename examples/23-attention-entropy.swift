// Title: Attention Entropy
//
// A transformer layer decides how much to look at each earlier word. Those
// weights form a probability distribution, and its entropy measures how the
// attention is spread: low entropy means the layer is focused on one or two
// words, high entropy means it is looking everywhere at once. Feeding a model
// ordinary text and then a defamiliarized version of it — the same meaning
// made strange — shifts that entropy, and the size of the shift is a signal
// that the model noticed the strangeness. Quiver cannot run a transformer to
// produce the weights, but once the weights exist the measurement is plain
// arithmetic. Here we supply two attention distributions by hand and compute
// the shift the way an interpretability study would.

// Shannon entropy of one attention distribution, in bits.
// H = −Σ pᵢ log₂ pᵢ, skipping zeros because 0·log 0 is defined as 0.
func entropy(_ p: [Double]) -> Double {
    let terms = p.map { $0 > 0 ? $0 * Foundation.log2($0) : 0 }
    return -terms.sum()
}

// One layer's attention over five words, reading ordinary text.
// The weight lands almost entirely on a single word — a focused, low-entropy layer.
let ordinary = [0.80, 0.10, 0.05, 0.03, 0.02]

// The same layer reading the defamiliarized version.
// Attention scatters as the layer works to make sense of the strangeness.
let strange = [0.30, 0.25, 0.20, 0.15, 0.10]

let hOrdinary = entropy(ordinary)
let hStrange = entropy(strange)

print("ordinary text entropy:", String(format: "%.4f", hOrdinary), "bits")
print("strange text entropy: ", String(format: "%.4f", hStrange), "bits")

// The detection signal: how much the strange text raised the entropy.
// A positive shift is the layer reacting to the defamiliarization.
let signal = hStrange - hOrdinary

print("detection signal:     ", String(format: "+%.4f", signal), "bits")
