import Foundation

/// Tracks the state of the sandbox pre-warm task so the frontend can display a "warming up" banner.
final class PrewarmStatus: @unchecked Sendable {
    static let shared = PrewarmStatus()

    enum State: String {
        case pending  // not started
        case running  // pre-warm in progress
        case ready    // pre-warm complete, sandbox cached
        case failed   // pre-warm errored; runs will still work, just slowly
    }

    private let lock = NSLock()
    private var _state: State = .pending
    private var _reason: String?

    private init() {}

    var state: State {
        lock.lock(); defer { lock.unlock() }
        return _state
    }

    var reason: String? {
        lock.lock(); defer { lock.unlock() }
        return _reason
    }

    func markRunning() {
        lock.lock(); defer { lock.unlock() }
        _state = .running
        _reason = nil
    }

    func markReady() {
        lock.lock(); defer { lock.unlock() }
        _state = .ready
        _reason = nil
    }

    func markFailed(reason: String) {
        lock.lock(); defer { lock.unlock() }
        _state = .failed
        _reason = reason
    }
}
