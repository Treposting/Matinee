import SwiftUI

/// A collapsible group in the menu bar window. The header always shows a one-line summary of
/// the settings inside, so the current state is readable without expanding it.
struct PopoverSection<Content: View>: View {
    let title: String
    let systemImage: String
    let summary: String
    @Binding var isExpanded: Bool
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.snappy(duration: 0.25)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Label(title, systemImage: systemImage)
                        .font(.subheadline.weight(.medium))
                    Spacer(minLength: 8)
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .monospacedDigit()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(title)
            .accessibilityValue(summary)
            .accessibilityHint(isExpanded ? "Collapse" : "Expand")

            if isExpanded {
                Divider()
                    .padding(.horizontal, 12)
                content
                    .padding(12)
                    .transition(.opacity)
            }
        }
        .background(.quinary, in: .rect(cornerRadius: 12))
    }
}
