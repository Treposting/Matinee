import SwiftUI

@main
struct MatineeApp: App {
    @State private var timer = FocusTimer()

    var body: some Scene {
        MenuBarExtra {
            TimerPopover()
                .environment(timer)
        } label: {
            MenuBarLabel(timer: timer)
        }
        .menuBarExtraStyle(.window)
    }
}
