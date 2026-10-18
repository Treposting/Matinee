import AppKit
import Observation
import SwiftUI

/// Covers every screen with the reminder until the user dismisses it or starts the next phase.
@MainActor
@Observable
final class ReminderOverlay {
    @ObservationIgnored private var panels: [NSPanel] = []
    @ObservationIgnored private var autoDismissTask: Task<Void, Never>?

    var isShowing: Bool { !panels.isEmpty }

    func show(_ reminder: Reminder, onAction: @escaping @MainActor () -> Void = {}) {
        dismiss()
        let endsAt = reminder.duration.map { Date.now.addingTimeInterval($0) }

        // Activate first so the panel made key below actually receives Esc and Return.
        NSApp.activate()

        for screen in NSScreen.screens {
            let view = ReminderOverlayView(
                reminder: reminder,
                endsAt: endsAt,
                onAction: { [weak self] in
                    self?.dismiss()
                    onAction()
                },
                onDismiss: { [weak self] in self?.dismiss() }
            )
            let panel = makePanel(covering: screen, content: view)
            panel.orderFrontRegardless()
            panels.append(panel)
        }

        let keyPanel = panels.first { $0.screen == NSScreen.main } ?? panels.first
        keyPanel?.makeKeyAndOrderFront(nil)

        if let duration = reminder.duration {
            autoDismissTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(duration))
                guard !Task.isCancelled else { return }
                self?.dismiss()
            }
        }
    }

    func dismiss() {
        autoDismissTask?.cancel()
        autoDismissTask = nil
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
        // Panels hide when the app deactivates by default; the reminder must stay until dismissed.
        panel.hidesOnDeactivate = false
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
