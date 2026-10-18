import Foundation

/// A reminder that comes from time spent at the screen, independent of the focus timer.
enum HealthBreak: String, CaseIterable, Identifiable, Sendable {
    case eyes
    case water
    case standUp

    static let intervalChoices = [10, 15, 20, 30, 45, 60, 90, 120]

    /// When several are due together only one is shown, the first in this order.
    static let priority: [HealthBreak] = [.standUp, .water, .eyes]

    var id: Self { self }

    var title: String {
        switch self {
        case .eyes: "Look away"
        case .water: "Drink water"
        case .standUp: "Stand up"
        }
    }

    var systemImage: String {
        switch self {
        case .eyes: "eye"
        case .water: "drop.fill"
        case .standUp: "figure.stand"
        }
    }

    var defaultMinutes: Int {
        switch self {
        case .eyes: 20
        case .water: 45
        case .standUp: 60
        }
    }

    /// Being away from the Mac this long counts as having taken this break.
    var awayResetsAfter: TimeInterval {
        switch self {
        case .eyes: 3 * 60
        case .water, .standUp: 5 * 60
        }
    }

    var reminder: Reminder {
        switch self {
        case .eyes:
            Reminder(
                title: "Look away",
                detail: "Rest your eyes on something far away until the countdown ends.",
                systemImage: systemImage,
                duration: 60
            )
        case .water:
            Reminder(
                title: "Drink some water",
                detail: "You've been at the screen a while. Have a glass of water.",
                systemImage: systemImage
            )
        case .standUp:
            Reminder(
                title: "Time to stand up",
                detail: "Get up, stretch and walk around for a couple of minutes.",
                systemImage: systemImage
            )
        }
    }
}
