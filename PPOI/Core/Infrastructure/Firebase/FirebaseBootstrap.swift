import Foundation
import FirebaseAppCheck
import FirebaseCore

enum FirebaseBootstrap {
    private(set) static var isConfigured = false

    static func configureIfNeeded() {
        guard !isConfigured else { return }

        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            SecureLogger.info("GoogleService-Info.plist 未配置 — Firestore フォールバックモード", category: .network)
            return
        }

        configureAppCheck()
        FirebaseApp.configure()
        isConfigured = true
    }

    private static func configureAppCheck() {
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(PPOIAppAttestProviderFactory())
        #endif
    }
}

/// Release 用: App Attest プロバイダファクトリ
private class PPOIAppAttestProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
        AppAttestProvider(app: app)
    }
}
