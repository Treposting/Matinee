import SwiftUI

struct ReminderSettingsView: View {
    @Environment(ReminderSettings.self) private var reminders
    @Environment(ReminderOverlay.self) private var overlay

    var body: some View {
        @Bindable var reminders = reminders

        VStack(alignment: .leading, spacing: 10) {
            Toggle("Show a full-screen reminder", isOn: $reminders.isEnabled)
                .toggleStyle(.switch)

            if reminders.isEnabled {
                Picker("Message", selection: $reminders.choice) {
                    ForEach(ReminderChoice.allCases) { choice in
                        Text(choice.menuTitle).tag(choice)
                    }
                }
                .pickerStyle(.menu)

                if reminders.choice == .custom {
                    TextField("Reminder text", text: $reminders.customText, prompt: Text("Take a walk"))
                        .textFieldStyle(.roundedBorder)
                }

                Button("Preview Reminder") {
                    guard let reminder = reminders.reminder(after: .focus) else { return }
                    overlay.show(reminder) {}
                }
                .buttonStyle(.link)
                .font(.caption)
                .help("Show the reminder now, the way it appears when focus time is up")
            }
        }
    }
}

extension ReminderSettings {
    /// One-line state for the collapsed section header.
    var summary: String {
        guard isEnabled else { return "Off" }
        if choice == .custom {
            let text = customText.trimmingCharacters(in: .whitespacesAndNewlines)
            return text.isEmpty ? ReminderChoice.standUp.menuTitle : text
        }
        return choice.menuTitle
    }
}
