import AppKit
import Observation

/// Watches screen time in the background and asks for a health break when one is due.
/// Settings are persisted in defaults.
@MainActor
@Observable
final class HealthBreaks {
    static let pollInterval: Duration = .seconds(30)

    private(set) var enabled: Set<HealthBreak>
    private(set) var minutes: [HealthBreak: Int]

    /// Called with the break to show.
    @ObservationIgnored var onBreakDue: (@MainActor (HealthBreak) -> Void)?

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var schedule = HealthBreakSchedule()
    @ObservationIgnored private var pollTask: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        var enabled = Set<HealthBreak>()
        var minutes: [HealthBreak: Int] = [:]
        for kind in HealthBreak.allCases {
            if defaults.object(forKey: Self.enabledKey(kind)) as? Bool ?? true {
                enabled.insert(kind)
            }
            minutes[kind] = defaults.object(forKey: Self.minutesKey(kind)) as? Int ?? kind.defaultMinutes
        }
        self.enabled = enabled
        self.minutes = minutes
        updateSchedule()
    }

    func isEnabled(_ kind: HealthBreak) -> Bool {
        enabled.contains(kind)
    }

    func setEnabled(_ isOn: Bool, for kind: HealthBreak) {
        if isOn { enabled.insert(kind) } else { enabled.remove(kind) }
        defaults.set(isOn, forKey: Self.enabledKey(kind))
        updateSchedule()
    }

    func minutes(for kind: HealthBreak) -> Int {
        minutes[kind] ?? kind.defaultMinutes
    }

    func setMinutes(_ value: Int, for kind: HealthBreak) {
        minutes[kind] = value
        defaults.set(value, forKey: Self.minutesKey(kind))
        updateSchedule()
    }

    func start() {
        guard pollTask == nil else { return }

        let center = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.willSleepNotification, NSWorkspace.screensDidSleepNotification, NSWorkspace.sessionDidResignActiveNotification] {
            _ = center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.schedule.reset() }
            }
        }

        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.poll()
                try? await Task.sleep(for: Self.pollInterval)
            }
        }
    }

    private func poll() {
        if let due = schedule.update(at: .now, idle: SystemIdle.seconds()) {
            onBreakDue?(due)
        }
    }

    private func updateSchedule() {
        schedule.intervals = Dictionary(
            uniqueKeysWithValues: enabled.map { ($0, TimeInterval(minutes(for: $0) * 60)) }
        )
    }

    private static func enabledKey(_ kind: HealthBreak) -> String { "health.\(kind.rawValue).enabled" }
    private static func minutesKey(_ kind: HealthBreak) -> String { "health.\(kind.rawValue).minutes" }
}

enum SystemIdle {
    /// Seconds since the last keyboard, mouse or trackpad input. Needs no permission.
    static func seconds() -> TimeInterval {
        guard let anyInput = CGEventType(rawValue: ~0) else { return 0 }
        return CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: anyInput)
    }
}
