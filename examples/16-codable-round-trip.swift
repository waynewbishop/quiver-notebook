// Title: Encode and Decode a Fitted Model
//
// Every Quiver model conforms to Codable, which means a fitted model is
// just bytes — JSON in, JSON out, identical predictions on the other
// side. The same encoded model that comes out of the Notebook drops
// into an iOS, watchOS, or visionOS target without a second framework
// or a conversion step.

let data: [[Double]] = [
    [1.0, 2.0], [1.5, 1.8], [1.2, 2.1],    // group A
    [5.0, 5.0], [5.5, 4.8], [4.8, 5.2],    // group B
    [9.0, 8.0], [8.5, 8.5], [9.2, 7.8]     // group C
]

let model = KMeans.fit(data: data, k: 3, seed: 1)
print(model)
print()

// Encode the fitted model to JSON.
let encoded = try JSONEncoder().encode(model)
print("encoded:", encoded.count, "bytes")
print()

// Decode it back, then confirm the round-trip preserved the model.
// KMeans is Equatable, so a single == settles it.
let restored = try JSONDecoder().decode(KMeans.self, from: encoded)
print("model == restored:", model == restored)
