import Foundation

/// Pure screen-time bookkeeping. Each break counts the time the user has been at the Mac since
/// they last took it; stepping away long enough counts as taking it.
struct HealthBreakSchedule: Equatable, Sendable {
    /// Gaps longer than this between updates mean the Mac was asleep.
    static let sleepGap: TimeInterval = 10 * 60

    /// Enabled breaks and how much screen time each allows.
    var intervals: [HealthBreak: TimeInterval] = [:]
    private(set) var screenTime: [HealthBreak: TimeInterval] = [:]
    private var lastUpdate: Date?

    init(intervals: [HealthBreak: TimeInterval] = [:]) {
        self.intervals = intervals
    }

    /// Records the time since the previous update and returns the break to show, if one is due.
    /// `idle` is how long it has been since the last keyboard or mouse input.
    mutating func update(at now: Date, idle: TimeInterval) -> HealthBreak? {
        defer { lastUpdate = now }
        guard let lastUpdate else { return nil }

        let elapsed = max(0, now.timeIntervalSince(lastUpdate))
        let away = elapsed > Self.sleepGap ? max(idle, elapsed) : idle

        var due: [HealthBreak] = []
        for (kind, interval) in intervals {
            if away >= kind.awayResetsAfter {
                screenTime[kind] = 0
                continue
            }
            let total = screenTime[kind, default: 0] + elapsed
            screenTime[kind] = total
            if total >= interval {
                due.append(kind)
            }
        }

        // Taking the most demanding break covers the others that are due with it.
        for kind in due {
            screenTime[kind] = 0
        }
        return HealthBreak.priority.first(where: due.contains)
    }

    /// Starts every count over, for example after the Mac wakes from sleep.
    mutating func reset() {
        screenTime = [:]
        lastUpdate = nil
    }
}
