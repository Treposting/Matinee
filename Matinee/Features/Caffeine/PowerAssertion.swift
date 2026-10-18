import Foundation
import IOKit.pwr_mgt

/// An IOKit power assertion that stops idle display sleep, which also stops idle system sleep.
/// The system drops it automatically if Matinee quits or crashes.
@MainActor
final class PowerAssertion {
    private let reason: String
    private var assertionID: IOPMAssertionID?

    var isHeld: Bool { assertionID != nil }

    init(reason: String) {
        self.reason = reason
    }

    func hold() {
        guard assertionID == nil else { return }
        var newID = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            "PreventUserIdleDisplaySleep" as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason as CFString,
            &newID
        )
        if result == kIOReturnSuccess {
            assertionID = newID
        }
    }

    func release() {
        guard let assertionID else { return }
        IOPMAssertionRelease(assertionID)
        self.assertionID = nil
    }
}
