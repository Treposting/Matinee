import SwiftUI

@main
struct MatineeApp: App {
    @State private var timer: FocusTimer
    @State private var updates = UpdateController()
    @State private var caffeine: CaffeineMode
    @State private var reminders: ReminderSettings
    @State private var overlay: ReminderOverlay
    @State private var healthBreaks: HealthBreaks

    init() {
        let timer = FocusTimer()
        let caffeine = CaffeineMode()
        let reminders = ReminderSettings()
        let overlay = ReminderOverlay()
        let healthBreaks = HealthBreaks()

        caffeine.follow(timer)
        timer.onPhaseFinished = { finished in
            guard let reminder = reminders.reminder(after: finished) else { return }
            overlay.show(reminder) { timer.start() }
        }
        healthBreaks.onBreakDue = { kind in
            guard !overlay.isShowing else { return }
            overlay.show(kind.reminder)
        }
        healthBreaks.start()

        _timer = State(initialValue: timer)
        _caffeine = State(initialValue: caffeine)
        _reminders = State(initialValue: reminders)
        _overlay = State(initialValue: overlay)
        _healthBreaks = State(initialValue: healthBreaks)
    }

    var body: some Scene {
        MenuBarExtra {
            TimerPopover()
                .environment(timer)
                .environment(updates)
                .environment(caffeine)
                .environment(reminders)
                .environment(overlay)
                .environment(healthBreaks)
        } label: {
            MenuBarLabel(timer: timer, updates: updates)
        }
        .menuBarExtraStyle(.window)
    }
}
