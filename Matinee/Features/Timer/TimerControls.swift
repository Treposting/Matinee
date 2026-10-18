import SwiftUI

struct TimerControls: View {
    @Environment(FocusTimer.self) private var timer

    var body: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: timer.toggle) {
                    Label(primaryTitle, systemImage: timer.isRunning ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .keyboardShortcut(.space, modifiers: [])

                Button(action: timer.stop) {
                    Label("Stop", systemImage: "stop.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.glass)
                .disabled(timer.isIdle && timer.phase == .focus)
                .help("Stop and reset to a new focus session")

                Button(action: timer.skip) {
                    Label("Skip", systemImage: "forward.end.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.glass)
                .help("Skip to \(timer.phase.next.title.lowercased())")
            }
            .controlSize(.large)
        }
    }

    private var primaryTitle: String {
        if timer.isRunning { "Pause" } else if timer.isIdle { "Start" } else { "Resume" }
    }
}
