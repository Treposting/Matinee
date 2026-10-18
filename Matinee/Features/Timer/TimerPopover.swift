import AppKit
import SwiftUI

/// Content of the menu bar window. The timer leads; settings sit below in collapsible groups
/// whose headers show their current values. The window itself is system glass, so the
/// groups use a light semantic fill rather than more glass.
struct TimerPopover: View {
    @Environment(FocusTimer.self) private var timer
    @Environment(UpdateController.self) private var updates
    @Environment(ReminderSettings.self) private var reminders
    @Environment(HealthBreaks.self) private var healthBreaks

    @AppStorage("popover.sessionExpanded") private var sessionExpanded = false
    @AppStorage("popover.remindersExpanded") private var remindersExpanded = false
    @AppStorage("popover.healthExpanded") private var healthExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            UpdateBanner()
            TimerDial()
            TimerControls()

            VStack(spacing: 8) {
                PopoverSection(
                    title: "Session",
                    systemImage: "timer",
                    summary: "\(timer.focusMinutes) / \(timer.restMinutes) min",
                    isExpanded: $sessionExpanded
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        DurationSettings()
                        Divider()
                        CaffeineToggle()
                    }
                }

                PopoverSection(
                    title: "When time's up",
                    systemImage: "bell",
                    summary: reminders.summary,
                    isExpanded: $remindersExpanded
                ) {
                    ReminderSettingsView()
                }

                PopoverSection(
                    title: "Screen-time breaks",
                    systemImage: "eye",
                    summary: healthBreaks.summary,
                    isExpanded: $healthExpanded
                ) {
                    HealthBreakSettings()
                }
            }

            footer
        }
        .padding(14)
        .frame(width: 300)
    }

    private var footer: some View {
        HStack {
            if updates.isEnabled && !updates.hasUpdate {
                Button("Check for Updates…") {
                    updates.checkForUpdates()
                }
            }
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
            .help("Quit Matinee")
        }
        .buttonStyle(.borderless)
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)
    }
}
