// Title: Cosine Similarity
//
// Cosine similarity measures the angle between two vectors. Values near
// 1.0 mean the vectors are aligned; values near 0 mean they are
// orthogonal; values near −1 mean they point in opposite directions.
// The magnitude of each vector is factored out, so two vectors of
// different lengths can still be judged as similar when their
// directions align.

let a = [1.0, 2.0, 3.0]
let b = [2.0, 4.0, 6.0]   // parallel to a
let c = [1.0, 0.0, 0.0]   // a very different direction

print("a vs b:", String(format: "%.4f", a.cosineOfAngle(with: b)))
print("a vs c:", String(format: "%.4f", a.cosineOfAngle(with: c)))
