// Title: Vector Addition and Broadcasting
//
// Quiver treats [Double] as a vector. Element-wise operations combine two
// vectors of the same length, and broadcasting applies a scalar to every
// element. The methods are named rather than operator-overloaded so they
// never shadow the standard library.

let a = [1.0, 2.0, 3.0, 4.0]
let b = [5.0, 6.0, 7.0, 8.0]

print("a + b:", a.add(b))
print("a * b:", a.multiply(b))
print("a * 2:", a.broadcast(multiplyingBy: 2.0))
print("a + 10:", a.broadcast(adding: 10.0))
