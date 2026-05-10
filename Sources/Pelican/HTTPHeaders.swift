import Foundation

public struct HTTPHeaders: Sendable {
    private var storage: [(name: String, value: String)] = []

    public init() {}

    public init(_ pairs: [(String, String)]) {
        self.storage = pairs.map { (name: $0.0, value: $0.1) }
    }

    public mutating func add(name: String, value: String) {
        storage.append((name: name, value: value))
    }

    public mutating func replaceOrAdd(name: String, value: String) {
        storage.removeAll { $0.name.caseInsensitiveCompare(name) == .orderedSame }
        storage.append((name: name, value: value))
    }

    public func first(name: String) -> String? {
        storage.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }?.value
    }

    public func all(name: String) -> [String] {
        storage
            .filter { $0.name.caseInsensitiveCompare(name) == .orderedSame }
            .map { $0.value }
    }

    public var pairs: [(name: String, value: String)] { storage }
}
