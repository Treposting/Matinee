import SwiftUI

@main
struct MatineeApp: App {
    @State private var timer: FocusTimer
    @State private var updates = UpdateController()
    @State private var caffeine: CaffeineMode
    @State private var reminders: ReminderSettings

    init() {
        let timer = FocusTimer()
        let caffeine = CaffeineMode()
        let reminders = ReminderSettings()
        let overlay = ReminderOverlay()

        caffeine.follow(timer)
        timer.onPhaseFinished = { finished in
            guard let reminder = reminders.reminder(after: finished) else { return }
            overlay.show(reminder) { timer.start() }
        }

        _timer = State(initialValue: timer)
        _caffeine = State(initialValue: caffeine)
        _reminders = State(initialValue: reminders)
    }

    var body: some Scene {
        MenuBarExtra {
            TimerPopover()
                .environment(timer)
                .environment(updates)
                .environment(caffeine)
                .environment(reminders)
        } label: {
            MenuBarLabel(timer: timer, updates: updates)
        }
        .menuBarExtraStyle(.window)
    }
}
