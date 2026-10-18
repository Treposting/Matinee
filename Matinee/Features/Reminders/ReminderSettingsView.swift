import SwiftUI

struct ReminderSettingsView: View {
    @Environment(ReminderSettings.self) private var reminders
    @Environment(ReminderOverlay.self) private var overlay

    var body: some View {
        @Bindable var reminders = reminders

        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $reminders.isEnabled) {
                Label("Reminder when time is up", systemImage: "bell.badge")
            }
            .toggleStyle(.switch)

            if reminders.isEnabled {
                HStack {
                    Picker("Reminder", selection: $reminders.choice) {
                        ForEach(ReminderChoice.allCases) { choice in
                            Text(choice.menuTitle).tag(choice)
                        }
                    }
                    .pickerStyle(.menu)

                    Button("Preview") {
                        guard let reminder = reminders.reminder(after: .focus) else { return }
                        overlay.show(reminder) {}
                    }
                    .help("Show the reminder now, the way it appears when focus time is up")
                }

                if reminders.choice == .custom {
                    TextField("Reminder text", text: $reminders.customText, prompt: Text("Take a walk"))
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }
}
