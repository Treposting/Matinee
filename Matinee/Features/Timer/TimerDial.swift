import SwiftUI

/// The countdown inside a ring that fills as the phase runs, tinted by phase.
struct TimerDial: View {
    @Environment(FocusTimer.self) private var timer
    @Environment(CaffeineMode.self) private var caffeine

    private let lineWidth: CGFloat = 7

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(timer.phase.tint.gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: timer.progress)

            VStack(spacing: 2) {
                Label(timer.phase.title, systemImage: timer.phase.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(timer.phase.tint)
                Text(timer.countdown)
                    .font(.system(size: 46, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.default, value: timer.countdown)
                status
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 184, height: 184)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(timer.phase.title), \(timer.countdown) remaining, \(statusText)")
    }

    private var status: some View {
        HStack(spacing: 4) {
            Text(statusText)
            if caffeine.isKeepingAwake {
                Image(systemName: "cup.and.heat.waves.fill")
                    .help("Caffeine is keeping your Mac awake")
            }
        }
    }

    private var statusText: String {
        if timer.isRunning {
            let end = timer.now.addingTimeInterval(timer.remaining)
            return "Ends at \(end.formatted(date: .omitted, time: .shortened))"
        } else if timer.isIdle {
            return "Ready"
        } else {
            return "Paused"
        }
    }
}
