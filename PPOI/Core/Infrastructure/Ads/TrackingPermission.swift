import GoogleMobileAds
import UIKit
import UserMessagingPlatform

enum TrackingPermission {
    /// UMP同意 → AdMob SDK初期化フロー。
    @MainActor
    static func requestAndInitializeAds() async {
        // 1. UMP: 同意情報を更新（GDPR/ePrivacy対応）
        await requestUMPConsent()

        // 2. AdMob SDK初期化
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

                let rootVC = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap(\.windows)
                    .first { $0.isKeyWindow }?
                    .rootViewController
                UMPConsentForm.loadAndPresentIfRequired(
                    from: rootVC
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
