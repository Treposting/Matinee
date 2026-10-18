import SwiftUI

/// Full-screen glass that blurs whatever is underneath, with the reminder in the middle.
struct ReminderOverlayView: View {
    let reminder: Reminder
    /// When the overlay closes itself, for reminders with a duration.
    let endsAt: Date?
    let onAction: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: reminder.systemImage)
                .font(.system(size: 72))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)

            Text(reminder.title)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)

            Text(reminder.detail)
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let endsAt {
                Text(timerInterval: Date.now...max(endsAt, .now), countsDown: true)
                    .font(.system(size: 64, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }

            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    if let actionTitle = reminder.actionTitle {
                        Button("Dismiss", action: onDismiss)
                            .buttonStyle(.glass)
                            .keyboardShortcut(.cancelAction)
                        Button(actionTitle, action: onAction)
                            .buttonStyle(.glassProminent)
                            .keyboardShortcut(.defaultAction)
                    } else {
                        Button(endsAt == nil ? "Done" : "Skip", action: onDismiss)
                            .buttonStyle(.glassProminent)
                            .keyboardShortcut(.defaultAction)
                            .background {
                                // Lets Esc close it too, like the two-button layout.
                                Button("Close", action: onDismiss)
                                    .keyboardShortcut(.cancelAction)
                                    .opacity(0)
                                    .accessibilityHidden(true)
                            }
                    }
                }
                .controlSize(.extraLarge)
            }
            .padding(.top, 12)
        }
        .padding(48)
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            // The dim keeps the reminder readable over any wallpaper; the glass blurs it.
            Rectangle()
                .fill(.black.opacity(0.35))
                .glassEffect(.regular, in: Rectangle())
                .ignoresSafeArea()
        }
        .environment(\.colorScheme, .dark)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}
