import AppKit
import SwiftUI

/// Covers every screen with the reminder until the user dismisses it or starts the next phase.
@MainActor
final class ReminderOverlay {
    private var panels: [NSPanel] = []

    var isShowing: Bool { !panels.isEmpty }

    func show(_ reminder: Reminder, onAction: @escaping @MainActor () -> Void) {
        dismiss()

        for screen in NSScreen.screens {
            let view = ReminderOverlayView(
                reminder: reminder,
                onAction: { [weak self] in
                    self?.dismiss()
                    onAction()
                },
                onDismiss: { [weak self] in self?.dismiss() }
            )
            let panel = makePanel(covering: screen, content: view)
            panel.orderFrontRegardless()
            if screen == NSScreen.main {
                panel.makeKey()
            }
            panels.append(panel)
        }

        NSApp.activate()
    }

    func dismiss() {
        panels.forEach { $0.orderOut(nil) }
        panels.removeAll()
    }

    private func makePanel(covering screen: NSScreen, content: ReminderOverlayView) -> NSPanel {
        let panel = OverlayPanel(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isReleasedWhenClosed = false

        let hostingView = NSHostingView(rootView: content)
        hostingView.sizingOptions = []
        panel.contentView = hostingView
        panel.setFrame(screen.frame, display: true)
        return panel
    }
}

/// Borderless panels can't take keyboard focus by default; the overlay needs it for Esc and Return.
private final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
