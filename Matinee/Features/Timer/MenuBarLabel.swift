import SwiftUI

/// The status item: an icon when idle, the live countdown while a phase is active, and a red
/// dot whenever an update is waiting.
struct MenuBarLabel: View {
    let timer: FocusTimer
    let updates: UpdateController

    var body: some View {
        if timer.isIdle {
            Image(nsImage: StatusIcon.symbol("timer", badged: updates.hasUpdate))
                .accessibilityLabel(updates.hasUpdate ? "Matinee, update available" : "Matinee")
        } else {
            HStack(spacing: 2) {
                Text(timer.countdown)
                    .monospacedDigit()
                if updates.hasUpdate {
                    Image(nsImage: StatusIcon.badge())
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(timer.phase.title), \(timer.countdown) remaining")
        }
    }
}
