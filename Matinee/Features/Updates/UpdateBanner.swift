import SwiftUI

/// Shown at the top of the menu bar window while an update is waiting.
struct UpdateBanner: View {
    @Environment(UpdateController.self) private var updates

    var body: some View {
        if let version = updates.availableVersion {
            HStack(spacing: 8) {
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Matinee \(version) is available")
                        .font(.subheadline.weight(.semibold))
                    Text("Matinee will quit and reopen to install it.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Button("Update") {
                    updates.installUpdate()
                }
                .buttonStyle(.glassProminent)
                .controlSize(.small)
            }
            .padding(10)
            .glassEffect(.regular.tint(.red.opacity(0.12)), in: .rect(cornerRadius: 12))
        }
    }
}
