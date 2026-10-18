import Foundation

struct TimerDurations: Equatable, Sendable {
    static let focusRange = 1...180
    static let restRange = 1...60
    static let standard = TimerDurations(focusMinutes: 25, restMinutes: 5)

    var focusMinutes: Int {
        didSet { focusMinutes = focusMinutes.clamped(to: Self.focusRange) }
    }
    var restMinutes: Int {
        didSet { restMinutes = restMinutes.clamped(to: Self.restRange) }
    }

    init(focusMinutes: Int, restMinutes: Int) {
        self.focusMinutes = focusMinutes.clamped(to: Self.focusRange)
        self.restMinutes = restMinutes.clamped(to: Self.restRange)
    }

    func length(of phase: TimerPhase) -> TimeInterval {
        switch phase {
        case .focus: TimeInterval(focusMinutes * 60)
        case .rest: TimeInterval(restMinutes * 60)
        }
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
