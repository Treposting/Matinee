import Foundation

/// Pure, clock-independent Pomodoro state. Every time-dependent call takes `now`
/// so the logic can be tested without waiting.
struct TimerSession: Equatable, Sendable {
    enum State: Equatable, Sendable {
        case idle
        case running(endsAt: Date)
        case paused(remaining: TimeInterval)
    }

    private(set) var phase: TimerPhase = .focus
    private(set) var state: State = .idle
    private(set) var durations: TimerDurations

    init(durations: TimerDurations = .standard) {
        self.durations = durations
    }

    var isRunning: Bool {
        if case .running = state { true } else { false }
    }

    var isIdle: Bool { state == .idle }

    var phaseLength: TimeInterval { durations.length(of: phase) }

    func remaining(at now: Date) -> TimeInterval {
        switch state {
        case .idle: phaseLength
        case .running(let endsAt): max(0, endsAt.timeIntervalSince(now))
        case .paused(let remaining): remaining
        }
    }

    func progress(at now: Date) -> Double {
        guard phaseLength > 0 else { return 0 }
        return (1 - remaining(at: now) / phaseLength).clamped(to: 0...1)
    }

    mutating func start(at now: Date) {
        switch state {
        case .idle: state = .running(endsAt: now.addingTimeInterval(phaseLength))
        case .paused(let remaining): state = .running(endsAt: now.addingTimeInterval(remaining))
        case .running: break
        }
    }

    mutating func pause(at now: Date) {
        guard isRunning else { return }
        state = .paused(remaining: remaining(at: now))
    }

    /// Ends the current session and returns to a fresh focus phase.
    mutating func stop() {
        phase = .focus
        state = .idle
    }

    /// Moves to the next phase without starting it.
    mutating func skip() {
        phase = phase.next
        state = .idle
    }

    /// If the running phase has reached zero, moves to the next phase (idle) and returns the
    /// phase that just finished.
    @discardableResult
    mutating func advanceIfFinished(at now: Date) -> TimerPhase? {
        guard isRunning, remaining(at: now) <= 0 else { return nil }
        let finished = phase
        skip()
        return finished
    }

    /// New lengths apply to idle phases immediately and to active phases from the next one.
    mutating func updateDurations(_ newDurations: TimerDurations) {
        durations = newDurations
    }
}
