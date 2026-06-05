import AppTrackingTransparency
import GoogleMobileAds
import UserMessagingPlatform

enum TrackingPermission {
    /// ATT + UMP同意 → AdMob SDK初期化の完全フロー。
    /// Apple要件: ATTダイアログはシーンが activeになった後に呼ぶ必要がある。
    @MainActor
    static func requestAndInitializeAds() async {
        // 1. UMP: 同意情報を更新（GDPR/ePrivacy対応）
        await requestUMPConsent()

        // 2. ATT: トラッキング許可をリクエスト（iOS 14.5+）
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            _ = await ATTrackingManager.requestTrackingAuthorization()
        }

        // 3. AdMob SDK初期化（ATT/UMP結果に関わらず広告は表示可能）
        AdMobCompliance.configureForLaunch()
        await withCheckedContinuation { continuation in
            GADMobileAds.sharedInstance().start { _ in
                continuation.resume()
            }
        }
        InterstitialAdManager.shared.preload()
    }

    private static func requestUMPConsent() async {
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false

        #if DEBUG
        let debugSettings = UMPDebugSettings()
        debugSettings.testDeviceIdentifiers = ["TEST-DEVICE"]
        parameters.debugSettings = debugSettings
        #endif

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(
                with: parameters
            ) { error in
                if let error {
                    SecureLogger.error("UMP consent update failed: \(error.localizedDescription)", category: .ads)
                    continuation.resume()
                    return
                }

                // 同意フォームが必要なら表示
                UMPConsentForm.loadAndPresentIfRequired(
                    from: nil
                ) { formError in
                    if let formError {
                        SecureLogger.error("UMP form error: \(formError.localizedDescription)", category: .ads)
                    }
                    continuation.resume()
                }
            }
        }
    }
}
