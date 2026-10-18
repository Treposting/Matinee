import SwiftUI

extension TimerPhase {
    /// Warm for work, cool for rest, so the phase reads at a glance in the dial and buttons.
    var tint: Color {
        switch self {
        case .focus: .orange
        case .rest: .teal
        }
    }
}
