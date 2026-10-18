import AppKit
import Observation

/// Drives a `TimerSession` against the real clock and persists the chosen lengths.
@MainActor
@Observable
final class FocusTimer {
    private enum Keys {
        static let focusMinutes = "timer.focusMinutes"
        static let restMinutes = "timer.restMinutes"
    }

    private(set) var session: TimerSession
    private(set) var now = Date.now

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var tickTask: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let focus = defaults.object(forKey: Keys.focusMinutes) as? Int ?? TimerDurations.standard.focusMinutes
        let rest = defaults.object(forKey: Keys.restMinutes) as? Int ?? TimerDurations.standard.restMinutes
        session = TimerSession(durations: TimerDurations(focusMinutes: focus, restMinutes: rest))
    }

    var phase: TimerPhase { session.phase }
    var isRunning: Bool { session.isRunning }
    var isIdle: Bool { session.isIdle }
    var remaining: TimeInterval { session.remaining(at: now) }
    var progress: Double { session.progress(at: now) }
    var countdown: String { CountdownFormat.string(from: remaining) }

    var focusMinutes: Int {
        get { session.durations.focusMinutes }
        set { updateDurations { $0.focusMinutes = newValue } }
    }

    var restMinutes: Int {
        get { session.durations.restMinutes }
        set { updateDurations { $0.restMinutes = newValue } }
    }

    func start() {
        now = .now
        session.start(at: now)
        startTicking()
    }

    func pause() {
        now = .now
        session.pause(at: now)
        stopTicking()
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func stop() {
        session.stop()
        now = .now
        stopTicking()
    }

    func skip() {
        session.skip()
        now = .now
        stopTicking()
    }

    private func updateDurations(_ change: (inout TimerDurations) -> Void) {
        var durations = session.durations
        change(&durations)
        session.updateDurations(durations)
        defaults.set(durations.focusMinutes, forKey: Keys.focusMinutes)
        defaults.set(durations.restMinutes, forKey: Keys.restMinutes)
    }

    private func startTicking() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))
                self?.tick()
            }
        }
    }

    private func stopTicking() {
        tickTask?.cancel()
        tickTask = nil
    }

    private func tick() {
        now = .now
        if session.advanceIfFinished(at: now) != nil {
            stopTicking()
            NSSound(named: "Glass")?.play()
        }
    }
}
