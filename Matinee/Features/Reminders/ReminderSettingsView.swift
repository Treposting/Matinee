import SwiftUI

struct ReminderSettingsView: View {
    @Environment(ReminderSettings.self) private var reminders

    var body: some View {
        @Bindable var reminders = reminders

        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $reminders.isEnabled) {
                Label("Reminder when time is up", systemImage: "bell.badge")
            }
            .toggleStyle(.switch)

            if reminders.isEnabled {
                Picker("Reminder", selection: $reminders.choice) {
                    ForEach(ReminderChoice.allCases) { choice in
                        Text(choice.menuTitle).tag(choice)
                    }
                }
                .pickerStyle(.menu)

                if reminders.choice == .custom {
                    TextField("Reminder text", text: $reminders.customText, prompt: Text("Take a walk"))
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }
}
