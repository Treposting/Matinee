import SwiftUI

/// Full-screen glass that blurs whatever is underneath, with the reminder in the middle.
struct ReminderOverlayView: View {
    let reminder: Reminder
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

            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Dismiss", action: onDismiss)
                        .buttonStyle(.glass)
                        .keyboardShortcut(.cancelAction)
                    Button(reminder.actionTitle, action: onAction)
                        .buttonStyle(.glassProminent)
                        .keyboardShortcut(.defaultAction)
                }
                .controlSize(.extraLarge)
            }
            .padding(.top, 12)
        }
        .padding(48)
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Rectangle()
                .fill(.clear)
                .glassEffect(.regular, in: Rectangle())
                .ignoresSafeArea()
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}
