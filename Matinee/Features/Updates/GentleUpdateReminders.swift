import Foundation
@preconcurrency import Sparkle

/// Tells Sparkle that Matinee shows its own reminder (red dot + notification) for updates
/// found in the background, instead of popping a window over the user's work.
@MainActor
final class GentleUpdateReminders: NSObject, @preconcurrency SPUStandardUserDriverDelegate {
    var onUpdateFound: (String) -> Void = { _ in }
    var onUserAttention: () -> Void = {}

    var supportsGentleScheduledUpdateReminders: Bool { true }

    func standardUserDriverShouldHandleShowingScheduledUpdate(
        _ update: SUAppcastItem,
        andInImmediateFocus immediateFocus: Bool
    ) -> Bool {
        false
    }

    func standardUserDriverWillHandleShowingUpdate(
        _ handleShowingUpdate: Bool,
        forUpdate update: SUAppcastItem,
        state: SPUUserUpdateState
    ) {
        guard !state.userInitiated else { return }
        onUpdateFound(update.displayVersionString)
    }

    func standardUserDriverDidReceiveUserAttention(forUpdate update: SUAppcastItem) {
        onUserAttention()
    }

    func standardUserDriverWillFinishUpdateSession() {
        onUserAttention()
    }
}
