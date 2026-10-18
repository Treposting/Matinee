import SwiftUI

@main
struct MatineeApp: App {
    @State private var timer = FocusTimer()
    @State private var updates = UpdateController()

    var body: some Scene {
        MenuBarExtra {
            TimerPopover()
                .environment(timer)
                .environment(updates)
        } label: {
            MenuBarLabel(timer: timer, updates: updates)
        }
        .menuBarExtraStyle(.window)
    }
}
