import Foundation
import Testing
@testable import Matinee

@MainActor
struct ReminderTests {
    let defaults: UserDefaults

    init() {
        let suite = "ReminderTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func defaultsToStandUpAfterFocus() {
        let settings = ReminderSettings(defaults: defaults)
        #expect(settings.isEnabled)
        #expect(settings.reminder(after: .focus)?.title == "Stand up")
        #expect(settings.reminder(after: .focus)?.actionTitle == "Start Break")
    }

    @Test func breakEndShowsBreakOver() {
        let settings = ReminderSettings(defaults: defaults)
        #expect(settings.reminder(after: .rest) == ReminderChoice.breakOver)
    }

    @Test func disabledShowsNothing() {
        let settings = ReminderSettings(defaults: defaults)
        settings.isEnabled = false
        #expect(settings.reminder(after: .focus) == nil)
        #expect(settings.reminder(after: .rest) == nil)
    }

    @Test func customTextIsTrimmedAndUsed() {
        let settings = ReminderSettings(defaults: defaults)
        settings.choice = .custom
        settings.customText = "  Call mom \n"
        #expect(settings.reminder(after: .focus)?.title == "Call mom")
    }

    @Test func blankCustomTextFallsBackToStandUp() {
        let settings = ReminderSettings(defaults: defaults)
        settings.choice = .custom
        settings.customText = "   "
        #expect(settings.reminder(after: .focus)?.title == "Stand up")
    }

    @Test func choicesPersist() {
        let settings = ReminderSettings(defaults: defaults)
        settings.choice = .drinkWater
        settings.isEnabled = false
        settings.customText = "Walk"

        let reloaded = ReminderSettings(defaults: defaults)
        #expect(reloaded.choice == .drinkWater)
        #expect(!reloaded.isEnabled)
        #expect(reloaded.customText == "Walk")
    }

    @Test func caffeineOnlyHoldsWhileEnabledAndRunning() {
        #expect(CaffeineMode.shouldKeepAwake(isEnabled: true, timerIsRunning: true))
        #expect(!CaffeineMode.shouldKeepAwake(isEnabled: true, timerIsRunning: false))
        #expect(!CaffeineMode.shouldKeepAwake(isEnabled: false, timerIsRunning: true))
    }
}
