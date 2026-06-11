import GoogleMobileAds
import SwiftUI

@Observable
final class AppState {
    var store: UserDefaultsStore

    var hasCompletedOnboarding: Bool

    init() {
        let defaults = UserDefaultsStore()
        store = defaults
        hasCompletedOnboarding = defaults.hasCompletedOnboarding
    }

    func finishOnboarding(requestNotification: Bool) {
        hasCompletedOnboarding = true
        store.hasCompletedOnboarding = true
        store.notificationEnabled = requestNotification
    }

    func updateNotificationPermission(granted: Bool) {
        store.notificationEnabled = granted
    }
}

@main
struct PPOIApp: App {
    @State private var appState = AppState()
    @State private var journalStore = JournalStore()
    @State private var achievementStore = AchievementStore()

    init() {
        // A2: Deny debugger attachment before any other initialization
        SecurityGuard.denyDebuggerAttachment()

        FirebaseBootstrap.configureIfNeeded()

        // AdMob SDK initialization is deferred to .task in body
        // (UMP consent must run after scene is active)

        // B2: Set file protection level to Complete for the app's data directory
        setFileProtection()
    }

    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
                .environment(journalStore)
                .environment(achievementStore)
                .task {
                    await TrackingPermission.requestAndInitializeAds()
                }
        }
    }

    /// B2: NSFileProtection Complete — data is inaccessible when device is locked
    private func setFileProtection() {
        #if !targetEnvironment(simulator)
            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                  let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
            else { return }

            let protectedDirectories = [documentsURL, libraryURL]
            for url in protectedDirectories {
                try? FileManager.default.setAttributes(
                    [.protectionKey: FileProtectionType.complete],
                    ofItemAtPath: url.path
                )
            }
        #endif
    }
}
