import Foundation
import Observation

/// Whether to show the end-of-phase overlay, and which reminder it shows. Persisted in defaults.
@MainActor
@Observable
final class ReminderSettings {
    private enum Keys {
        static let isEnabled = "reminders.isEnabled"
        static let choice = "reminders.choice"
        static let customText = "reminders.customText"
    }

    var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: Keys.isEnabled) }
    }
    var choice: ReminderChoice {
        didSet { defaults.set(choice.rawValue, forKey: Keys.choice) }
    }
    var customText: String {
        didSet { defaults.set(customText, forKey: Keys.customText) }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isEnabled = defaults.object(forKey: Keys.isEnabled) as? Bool ?? true
        choice = defaults.string(forKey: Keys.choice).flatMap(ReminderChoice.init(rawValue:)) ?? .standUp
        customText = defaults.string(forKey: Keys.customText) ?? ""
    }

    /// The overlay to show once `finished` reaches zero, or nil when reminders are off.
    func reminder(after finished: TimerPhase) -> Reminder? {
        guard isEnabled else { return nil }
        switch finished {
        case .focus: return choice.reminder(customText: customText)
        case .rest: return ReminderChoice.breakOver
        }
    }
}
