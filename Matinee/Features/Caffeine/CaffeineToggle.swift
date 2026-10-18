import SwiftUI

struct CaffeineToggle: View {
    @Environment(CaffeineMode.self) private var caffeine

    var body: some View {
        @Bindable var caffeine = caffeine

        Toggle(isOn: $caffeine.isEnabled) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Caffeine")
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: caffeine.isKeepingAwake ? "cup.and.heat.waves.fill" : "cup.and.heat.waves")
            }
        }
        .toggleStyle(.switch)
        .help("Keep the Mac and screen awake until the timer ends")
    }

    private var caption: String {
        caffeine.isKeepingAwake ? "Keeping your Mac awake now" : "Keeps your Mac awake while the timer runs"
    }
}
