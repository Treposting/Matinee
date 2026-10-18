import Foundation

/// What the full-screen overlay says when a phase ends.
struct Reminder: Equatable, Sendable {
    let title: String
    let detail: String
    let systemImage: String
    /// Label of the button that starts the next phase.
    let actionTitle: String
}

enum ReminderChoice: String, CaseIterable, Identifiable, Sendable {
    case standUp
    case drinkWater
    case restEyes
    case stretch
    case custom

    var id: Self { self }

    var menuTitle: String {
        switch self {
        case .standUp: "Stand up"
        case .drinkWater: "Drink water"
        case .restEyes: "Rest your eyes"
        case .stretch: "Stretch"
        case .custom: "Custom…"
        }
    }

    /// The overlay for the end of a focus session. A blank custom text falls back to "Stand up".
    func reminder(customText: String) -> Reminder {
        let breakAction = "Start Break"
        switch self {
        case .standUp:
            return Reminder(
                title: "Stand up",
                detail: "Get up and move around for a minute.",
                systemImage: "figure.stand",
                actionTitle: breakAction
            )
        case .drinkWater:
            return Reminder(
                title: "Drink some water",
                detail: "Refill your glass before the next session.",
                systemImage: "drop.fill",
                actionTitle: breakAction
            )
        case .restEyes:
            return Reminder(
                title: "Rest your eyes",
                detail: "Look at something far away for 20 seconds.",
                systemImage: "eye",
                actionTitle: breakAction
            )
        case .stretch:
            return Reminder(
                title: "Stretch",
                detail: "Roll your shoulders and stretch your back.",
                systemImage: "figure.flexibility",
                actionTitle: breakAction
            )
        case .custom:
            let text = customText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return ReminderChoice.standUp.reminder(customText: "") }
            return Reminder(
                title: text,
                detail: "Your focus session is done.",
                systemImage: "bell.fill",
                actionTitle: breakAction
            )
        }
    }

    static let breakOver = Reminder(
        title: "Break's over",
        detail: "Ready for the next focus session?",
        systemImage: "brain.head.profile",
        actionTitle: "Start Focus"
    )
}
