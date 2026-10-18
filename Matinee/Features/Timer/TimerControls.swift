import SwiftUI

struct TimerControls: View {
    @Environment(FocusTimer.self) private var timer

    var body: some View {
        GlassEffectContainer(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    timer.stop()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .disabled(timer.isIdle && timer.phase == .focus)
                .help("Stop and reset to a new focus session")

                Button {
                    timer.toggle()
                } label: {
                    Label(primaryTitle, systemImage: timer.isRunning ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .tint(timer.phase.tint)
                .keyboardShortcut(.space, modifiers: [])

                Button {
                    timer.skip()
                } label: {
                    Label("Skip", systemImage: "forward.end.fill")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .help("Skip to \(timer.phase.next.title.lowercased())")
            }
            .controlSize(.large)
        }
    }

    private var primaryTitle: String {
        if timer.isRunning { "Pause" } else if timer.isIdle { "Start \(timer.phase.title)" } else { "Resume" }
    }
}
