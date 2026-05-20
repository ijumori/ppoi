import GoogleMobileAds
import SwiftUI

@Observable
final class AppState {
    var store = UserDefaultsStore()

    /// RootView の表示切替用（@Observable で直接監視）
    var hasCompletedOnboarding: Bool

    init() {
        hasCompletedOnboarding = UserDefaultsStore().hasCompletedOnboarding
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

    init() {
        FirebaseBootstrap.configureIfNeeded()
        AdMobCompliance.configureForLaunch()
        GADMobileAds.sharedInstance().start { _ in
            Task { @MainActor in
                InterstitialAdManager.shared.preload()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(appState: appState)
        }
    }
}
