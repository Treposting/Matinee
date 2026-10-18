import Foundation
import Observation

/// When on, keeps the Mac and its display from sleeping while the timer is running, and lets
/// them sleep normally again as soon as the timer pauses, stops or finishes.
@MainActor
@Observable
final class CaffeineMode {
    private static let isEnabledKey = "caffeine.isEnabled"

    var isEnabled: Bool {
        didSet {
            defaults.set(isEnabled, forKey: Self.isEnabledKey)
            refresh()
        }
    }

    private(set) var isKeepingAwake = false

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let assertion = PowerAssertion(reason: "Matinee timer is running")
    @ObservationIgnored private var timerIsRunning = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isEnabled = defaults.bool(forKey: Self.isEnabledKey)
    }

    static func shouldKeepAwake(isEnabled: Bool, timerIsRunning: Bool) -> Bool {
        isEnabled && timerIsRunning
    }

    /// Follows `timer.isRunning` for the life of the app.
    func follow(_ timer: FocusTimer) {
        timerIsRunning = withObservationTracking {
            timer.isRunning
        } onChange: {
            Task { @MainActor in self.follow(timer) }
        }
        refresh()
    }

    private func refresh() {
        if Self.shouldKeepAwake(isEnabled: isEnabled, timerIsRunning: timerIsRunning) {
            assertion.hold()
        } else {
            assertion.release()
        }
        isKeepingAwake = assertion.isHeld
    }
}
