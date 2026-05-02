// Title: Binary Search in Swift
//
// Binary search is the algorithm everyone writes at least once — find a
// value in a sorted array by halving the search space at every step. The
// array must be sorted in ascending order; the cost of sorting is O(n log n)
// upfront, but lookups afterward are O(log n) instead of O(n). For a
// sorted array of one million numbers, that is roughly 20 comparisons
// instead of one million.
//
// The implementation below is iterative — easier to read and avoids the
// recursive call stack. It returns the index when the value is present,
// and nil when it isn't.

func binarySearch<T: Comparable>(_ values: [T], for target: T) -> Int? {
    var low = 0
    var high = values.count - 1

    while low <= high {
        let mid = low + (high - low) / 2
        let candidate = values[mid]

        if candidate == target {
            return mid
        } else if candidate < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return nil
}

let sorted = [1, 3, 5, 7, 9, 11, 14, 18, 22, 27, 33, 41, 50, 64, 81]

print("found 22 at index:", binarySearch(sorted, for: 22) ?? -1)
print("found  1 at index:", binarySearch(sorted, for: 1) ?? -1)
print("found 81 at index:", binarySearch(sorted, for: 81) ?? -1)
print("found 99 at index:", binarySearch(sorted, for: 99) ?? -1)  // not present

// Worst-case comparisons for a 1,000,000-element array: ceil(log2(1_000_000)) = 20.
// A brute-force linear scan would compare every element until it found the match
// or hit the end. The improvement is the entire reason sorted data structures
// (and Quiver's similarity APIs, which sort by score) earn their keep.
