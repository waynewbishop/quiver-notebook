import Foundation

/// Generates the per-launch token the editor page must send with state-changing requests.
enum SessionToken {
    /// Returns 32 random bytes as a 64-character lowercase hex string.
    static func generate() -> String {
        var generator = SystemRandomNumberGenerator()
        return (0..<32).map { _ in String(format: "%02x", UInt8.random(in: .min ... .max, using: &generator)) }.joined()
    }
}
