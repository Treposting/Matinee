import AppKit
import Observation
@preconcurrency import Sparkle

/// Owns Sparkle and exposes whether an update is waiting, so the menu bar can show a red dot.
/// Sparkle verifies the download's EdDSA signature, quits Matinee, replaces it and relaunches.
@MainActor
@Observable
final class UpdateController {
    private(set) var availableVersion: String?
    let isEnabled: Bool

    var hasUpdate: Bool { availableVersion != nil }

    @ObservationIgnored private var updaterController: SPUStandardUpdaterController?
    @ObservationIgnored private let reminders = GentleUpdateReminders()
    @ObservationIgnored private let notifier = UpdateNotifier()

    init(bundle: Bundle = .main) {
        let publicKey = bundle.object(forInfoDictionaryKey: "SUPublicEDKey") as? String ?? ""
        isEnabled = !publicKey.isEmpty
        guard isEnabled else { return }

        reminders.onUpdateFound = { [weak self] version in self?.updateFound(version: version) }
        reminders.onUserAttention = { [weak self] in self?.updateSeen() }
        notifier.onOpen = { [weak self] in self?.installUpdate() }
        notifier.removeNotification()

        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: reminders
        )
    }

    /// Brings Sparkle's update window forward; from there the user installs and relaunches.
    func installUpdate() {
        checkForUpdates()
    }

    func checkForUpdates() {
        guard let updaterController else { return }
        NSApp.activate()
        updaterController.checkForUpdates(nil)
    }

    private func updateFound(version: String) {
        availableVersion = version
        Task { await notifier.notifyUpdateAvailable(version: version) }
    }

    private func updateSeen() {
        availableVersion = nil
        notifier.removeNotification()
    }
}
