import SwiftUI

struct HealthBreakSettings: View {
    @Environment(HealthBreaks.self) private var healthBreaks
    @Environment(ReminderOverlay.self) private var overlay

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reminders based on how long you've been at the screen, even with the timer off.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(HealthBreak.allCases) { kind in
                row(for: kind)
            }

            Menu("Preview Reminder") {
                ForEach(HealthBreak.allCases) { kind in
                    Button(kind.title, systemImage: kind.systemImage) {
                        overlay.show(kind.reminder)
                    }
                }
            }
            .menuStyle(.button)
            .buttonStyle(.borderless)
            .font(.caption)
            .fixedSize()
        }
    }

    private func row(for kind: HealthBreak) -> some View {
        HStack(spacing: 8) {
            Label(kind.title, systemImage: kind.systemImage)
                .foregroundStyle(healthBreaks.isEnabled(kind) ? .primary : .secondary)

            Spacer(minLength: 4)

            Picker("Every", selection: minutesBinding(kind)) {
                ForEach(HealthBreak.intervalChoices, id: \.self) { minutes in
                    Text("Every \(minutes) min").tag(minutes)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .controlSize(.small)
            .fixedSize()
            .disabled(!healthBreaks.isEnabled(kind))

            Toggle(kind.title, isOn: enabledBinding(kind))
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.mini)
        }
    }

    private func enabledBinding(_ kind: HealthBreak) -> Binding<Bool> {
        Binding(
            get: { healthBreaks.isEnabled(kind) },
            set: { healthBreaks.setEnabled($0, for: kind) }
        )
    }

    private func minutesBinding(_ kind: HealthBreak) -> Binding<Int> {
        Binding(
            get: { healthBreaks.minutes(for: kind) },
            set: { healthBreaks.setMinutes($0, for: kind) }
        )
    }
}

extension HealthBreaks {
    /// One-line state for the collapsed section header.
    var summary: String {
        switch enabled.count {
        case 0: "Off"
        case HealthBreak.allCases.count: "All on"
        default: "\(enabled.count) on"
        }
    }
}
