// Title: Normalize a Vector
//
// A vector's magnitude is its Euclidean length. A normalized vector has
// the same direction but a magnitude of 1.0, which lets it be compared
// against other vectors by angle alone. Normalization is the foundation
// of cosine similarity.

let v = [3.0, 4.0]

print("vector:   ", v)
print("magnitude:", v.magnitude)

let unit = v.normalized

print("normalized:          ", unit)
print("magnitude of unit:   ", unit.magnitude)
