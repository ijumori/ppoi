import Foundation
import FirebaseCore

enum FirebaseBootstrap {
    private(set) static var isConfigured = false

    static func configureIfNeeded() {
        guard !isConfigured else { return }

        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            #if DEBUG
            print("[PPOI] GoogleService-Info.plist 未配置 — Firestore フォールバックモード")
            #endif
            return
        }

        FirebaseApp.configure()
        isConfigured = true
    }
}
