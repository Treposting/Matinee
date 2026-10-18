import Foundation
import Testing
@testable import Matinee

struct HealthBreakScheduleTests {
    let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    /// Advances in 30-second steps with the given idle time and returns every break that fired.
    private func run(
        _ schedule: inout HealthBreakSchedule,
        from: TimeInterval,
        to: TimeInterval,
        idle: TimeInterval = 0
    ) -> [HealthBreak] {
        var fired: [HealthBreak] = []
        var t = from
        while t <= to {
            if let due = schedule.update(at: start.addingTimeInterval(t), idle: idle) {
                fired.append(due)
            }
            t += 30
        }
        return fired
    }

    @Test func firesAfterContinuousScreenTime() {
        var schedule = HealthBreakSchedule(intervals: [.eyes: 20 * 60])
        #expect(run(&schedule, from: 0, to: 20 * 60 - 30).isEmpty)
        #expect(run(&schedule, from: 20 * 60, to: 20 * 60) == [.eyes])
    }

    @Test func countStartsOverAfterItFires() {
        var schedule = HealthBreakSchedule(intervals: [.eyes: 20 * 60])
        #expect(run(&schedule, from: 0, to: 40 * 60) == [.eyes, .eyes])
    }

    @Test func steppingAwayCountsAsTheBreak() {
        var schedule = HealthBreakSchedule(intervals: [.eyes: 20 * 60])
        _ = run(&schedule, from: 0, to: 15 * 60)
        _ = schedule.update(at: start.addingTimeInterval(15 * 60 + 30), idle: 4 * 60)
        #expect(run(&schedule, from: 16 * 60, to: 30 * 60).isEmpty)
    }

    @Test func shortPausesStillCount() {
        var schedule = HealthBreakSchedule(intervals: [.eyes: 20 * 60])
        #expect(run(&schedule, from: 0, to: 20 * 60, idle: 45) == [.eyes])
    }

    @Test func sleepGapStartsOver() {
        var schedule = HealthBreakSchedule(intervals: [.standUp: 60 * 60])
        _ = run(&schedule, from: 0, to: 50 * 60)
        #expect(schedule.update(at: start.addingTimeInterval(3 * 60 * 60), idle: 0) == nil)
        #expect(schedule.screenTime[.standUp] == 0)
    }

    @Test func biggestBreakWinsAndCoversTheOthers() {
        var schedule = HealthBreakSchedule(intervals: [.eyes: 30 * 60, .standUp: 30 * 60])
        #expect(run(&schedule, from: 0, to: 30 * 60) == [.standUp])
        #expect(schedule.screenTime[.eyes] == 0)
    }

    @Test func disabledBreaksNeverFire() {
        var schedule = HealthBreakSchedule(intervals: [:])
        #expect(run(&schedule, from: 0, to: 3 * 60 * 60).isEmpty)
    }

    @Test func resetForgetsScreenTime() {
        var schedule = HealthBreakSchedule(intervals: [.water: 45 * 60])
        _ = run(&schedule, from: 0, to: 40 * 60)
        schedule.reset()
        #expect(run(&schedule, from: 41 * 60, to: 80 * 60).isEmpty)
    }

    @Test func eyeBreakCountsDownAndHasNoNextPhase() {
        #expect(HealthBreak.eyes.reminder.duration == 60)
        #expect(HealthBreak.eyes.reminder.actionTitle == nil)
        #expect(HealthBreak.standUp.reminder.duration == nil)
    }
}
