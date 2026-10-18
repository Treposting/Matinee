import Foundation
import Testing
@testable import Matinee

struct TimerSessionTests {
    let start = Date(timeIntervalSinceReferenceDate: 1_000_000)

    @Test func defaultsToTwentyFiveFiveIdleFocus() {
        let session = TimerSession()
        #expect(session.phase == .focus)
        #expect(session.isIdle)
        #expect(session.remaining(at: start) == 25 * 60)
        #expect(session.durations.length(of: .rest) == 5 * 60)
    }

    @Test func countsDownWhileRunning() {
        var session = TimerSession()
        session.start(at: start)
        #expect(session.isRunning)
        #expect(session.remaining(at: start.addingTimeInterval(60)) == 24 * 60)
    }

    @Test func pauseFreezesRemainingAndResumeContinues() {
        var session = TimerSession()
        session.start(at: start)
        session.pause(at: start.addingTimeInterval(100))
        #expect(session.state == .paused(remaining: 1400))
        #expect(session.remaining(at: start.addingTimeInterval(10_000)) == 1400)

        let resume = start.addingTimeInterval(5_000)
        session.start(at: resume)
        #expect(session.remaining(at: resume.addingTimeInterval(400)) == 1000)
    }

    @Test func startWhileRunningDoesNotReset() {
        var session = TimerSession()
        session.start(at: start)
        session.start(at: start.addingTimeInterval(300))
        #expect(session.remaining(at: start.addingTimeInterval(300)) == 1200)
    }

    @Test func stopReturnsToFreshFocus() {
        var session = TimerSession()
        session.skip()
        session.start(at: start)
        session.stop()
        #expect(session.phase == .focus)
        #expect(session.isIdle)
        #expect(session.remaining(at: start) == 25 * 60)
    }

    @Test func finishingFocusMovesToIdleBreak() {
        var session = TimerSession()
        session.start(at: start)
        #expect(session.advanceIfFinished(at: start.addingTimeInterval(1499)) == nil)

        let finished = session.advanceIfFinished(at: start.addingTimeInterval(1500))
        #expect(finished == .focus)
        #expect(session.phase == .rest)
        #expect(session.isIdle)
        #expect(session.remaining(at: start) == 5 * 60)
    }

    @Test func finishingBreakMovesBackToFocus() {
        var session = TimerSession()
        session.skip()
        session.start(at: start)
        #expect(session.advanceIfFinished(at: start.addingTimeInterval(400)) == .rest)
        #expect(session.phase == .focus)
    }

    @Test func remainingNeverGoesNegative() {
        var session = TimerSession()
        session.start(at: start)
        #expect(session.remaining(at: start.addingTimeInterval(99_999)) == 0)
        #expect(session.progress(at: start.addingTimeInterval(99_999)) == 1)
    }

    @Test func customDurationsApplyToIdlePhase() {
        var session = TimerSession()
        session.updateDurations(TimerDurations(focusMinutes: 50, restMinutes: 10))
        #expect(session.remaining(at: start) == 50 * 60)
        session.skip()
        #expect(session.remaining(at: start) == 10 * 60)
    }

    @Test func customDurationsDoNotChangeRunningCountdown() {
        var session = TimerSession()
        session.start(at: start)
        session.updateDurations(TimerDurations(focusMinutes: 50, restMinutes: 10))
        #expect(session.remaining(at: start.addingTimeInterval(60)) == 24 * 60)
    }

    @Test func durationsAreClampedToAllowedRanges() {
        var durations = TimerDurations(focusMinutes: 0, restMinutes: 500)
        #expect(durations.focusMinutes == 1)
        #expect(durations.restMinutes == 60)
        durations.focusMinutes = 1000
        #expect(durations.focusMinutes == 180)
    }
}

struct CountdownFormatTests {
    @Test(arguments: [
        (1500.0, "25:00"),
        (1499.2, "25:00"),
        (59.0, "00:59"),
        (0.4, "00:01"),
        (0.0, "00:00"),
        (-5.0, "00:00"),
        (5400.0, "90:00"),
    ])
    func formatsMinutesAndSeconds(seconds: Double, expected: String) {
        #expect(CountdownFormat.string(from: seconds) == expected)
    }
}
