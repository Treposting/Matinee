import SwiftUI

struct DurationSettings: View {
    @Environment(FocusTimer.self) private var timer

    var body: some View {
        @Bindable var timer = timer

        VStack(alignment: .leading, spacing: 8) {
            Stepper(value: $timer.focusMinutes, in: TimerDurations.focusRange) {
                LabeledContent("Focus", value: "\(timer.focusMinutes) min")
            }
            Stepper(value: $timer.restMinutes, in: TimerDurations.restRange) {
                LabeledContent("Break", value: "\(timer.restMinutes) min")
            }
        }
        .monospacedDigit()
    }
}
