import SwiftUI

/// Full-screen glass that blurs whatever is underneath, with the reminder in the middle.
struct ReminderOverlayView: View {
    let reminder: Reminder
    /// When the overlay closes itself, for reminders with a duration.
    let endsAt: Date?
    let onAction: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: reminder.systemImage)
                .font(.system(size: 64, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .frame(width: 148, height: 148)
                .glassEffect(.regular.tint(.accentColor.opacity(0.2)), in: .circle)
                .symbolEffect(.bounce, value: hasAppeared)

            VStack(spacing: 12) {
                Text(reminder.title)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text(reminder.detail)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 520)
            }

            if let endsAt {
                Text(timerInterval: Date.now...max(endsAt, .now), countsDown: true)
                    .font(.system(size: 72, weight: .light, design: .rounded))
                    .monospacedDigit()
            }

            VStack(spacing: 14) {
                buttons
                Text(keyboardHint)
                    .font(.callout)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 8)
        }
        .padding(48)
        .frame(maxWidth: 760)
        .scaleEffect(hasAppeared || reduceMotion ? 1 : 0.96)
        .opacity(hasAppeared ? 1 : 0)
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
        .onAppear {
            withAnimation(.smooth(duration: reduceMotion ? 0.2 : 0.45)) { hasAppeared = true }
        }
    }

    private var buttons: some View {
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
    }

    private var keyboardHint: String {
        if let actionTitle = reminder.actionTitle {
            "Press Return to \(actionTitle.lowercased()), or Esc to dismiss."
        } else {
            "Press Return or Esc to close."
        }
    }
}
