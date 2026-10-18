import AppKit
import SwiftUI

/// Content of the menu bar window. The window itself is system glass; the controls use
/// the glass button styles so nothing here fakes translucency.
struct TimerPopover: View {
    @Environment(FocusTimer.self) private var timer

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            countdown
            TimerControls()
            Divider()
            DurationSettings()
            Divider()
            footer
        }
        .padding(16)
        .frame(width: 280)
    }

    private var header: some View {
        HStack {
            Label(timer.phase.title, systemImage: timer.phase.systemImage)
                .font(.headline)
            Spacer()
            Text(status)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var countdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(timer.countdown)
                .font(.system(size: 52, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: true))
                .animation(.default, value: timer.countdown)
                .frame(maxWidth: .infinity, alignment: .center)
            ProgressView(value: timer.progress)
                .tint(timer.phase == .focus ? Color.accentColor : Color.green)
        }
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button("Quit Matinee") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }

    private var status: String {
        if timer.isRunning { "Running" } else if timer.isIdle { "Ready" } else { "Paused" }
    }
}
