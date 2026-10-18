import Foundation

enum CountdownFormat {
    /// Formats seconds as `MM:SS`, rounding up so a fresh 25-minute timer reads `25:00`
    /// and the display only shows `00:00` when time is actually up.
    static func string(from seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded(.up)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
