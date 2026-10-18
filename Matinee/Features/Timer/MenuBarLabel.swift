import SwiftUI

/// The status item: an icon when idle, the live countdown while a phase is active.
struct MenuBarLabel: View {
    let timer: FocusTimer

    var body: some View {
        if timer.isIdle {
            Image(systemName: "timer")
                .accessibilityLabel("Matinee")
        } else {
            Text(timer.countdown)
                .monospacedDigit()
                .accessibilityLabel("\(timer.phase.title), \(timer.countdown) remaining")
        }
    }
}
