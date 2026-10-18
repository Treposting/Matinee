enum TimerPhase: String, Sendable, CaseIterable {
    case focus
    case rest

    var next: TimerPhase {
        switch self {
        case .focus: .rest
        case .rest: .focus
        }
    }

    var title: String {
        switch self {
        case .focus: "Focus"
        case .rest: "Break"
        }
    }

    var systemImage: String {
        switch self {
        case .focus: "brain.head.profile"
        case .rest: "cup.and.saucer"
        }
    }
}
