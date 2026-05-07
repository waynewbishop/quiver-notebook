// Title: Vector Addition and Element-Wise Operations
//
// Quiver treats [Double] as a vector. Element-wise operations between two
// vectors of the same length use named methods (add, multiply) so they
// never shadow the standard library. Scalar broadcasting — applying one
// number to every element — uses operators (-, *, /) and reads like the
// formula on paper.

let a = [1.0, 2.0, 3.0, 4.0]
let b = [5.0, 6.0, 7.0, 8.0]

print("a + b:", a.add(b))
print("a * b:", a.multiply(b))
print("a * 2:", a.broadcast(multiplyingBy: 2.0))
print("a + 10:", a.broadcast(adding: 10.0))
