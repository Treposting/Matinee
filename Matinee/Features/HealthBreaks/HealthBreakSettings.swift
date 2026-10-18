import SwiftUI

struct HealthBreakSettings: View {
    @Environment(HealthBreaks.self) private var healthBreaks
    @Environment(ReminderOverlay.self) private var overlay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Screen-time breaks")
                .font(.headline)

            ForEach(HealthBreak.allCases) { kind in
                HStack {
                    Toggle(isOn: enabledBinding(kind)) {
                        Label(kind.title, systemImage: kind.systemImage)
                    }
                    .toggleStyle(.switch)
                    .controlSize(.small)

                    Spacer()

                    Picker("Every", selection: minutesBinding(kind)) {
                        ForEach(HealthBreak.intervalChoices, id: \.self) { minutes in
                            Text("every \(minutes) min").tag(minutes)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .fixedSize()
                    .disabled(!healthBreaks.isEnabled(kind))

                    Button {
                        overlay.show(kind.reminder)
                    } label: {
                        Label("Preview", systemImage: "eye.square")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderless)
                    .help("Preview this reminder")
                }
            }
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
