// Title: Cosine Similarity
//
// Cosine similarity measures the angle between two vectors. Values near
// 1.0 mean the vectors point in the same direction; values near 0 mean
// they are unrelated. The magnitude of each vector is factored out, so
// two vectors of different lengths can still be judged as similar if
// their directions align.

let a = [1.0, 2.0, 3.0]
let b = [2.0, 4.0, 6.0]   // parallel to a
let c = [1.0, 0.0, 0.0]   // a very different direction

print("a vs b:", a.cosineOfAngle(with: b))
print("a vs c:", a.cosineOfAngle(with: c))
