import GoogleMobileAds
import UIKit

@MainActor
final class InterstitialAdManager: NSObject {
    static let shared = InterstitialAdManager()

    private var interstitial: GADInterstitialAd?
    private var isLoading = false

    func preload() {
        guard !isLoading, interstitial == nil else { return }
        AdMobCompliance.assertSafeConfiguration()
        isLoading = true

        GADInterstitialAd.load(
            withAdUnitID: AdMobConfig.interstitialUnitID,
            request: AdMobConfig.makeAdRequest()
        ) { [weak self] ad, error in
            Task { @MainActor in
                self?.isLoading = false
                if let error {
                    SecureLogger.error("Interstitial load failed: \(error.localizedDescription)", category: .ads)
                    return
                }
                self?.interstitial = ad
                self?.interstitial?.fullScreenContentDelegate = self
            }
        }
    }

    func showIfReady() {
        guard let interstitial else {
            preload()
            return
        }

        guard let presenter = topPresenter() else {
            preload()
            return
        }

        interstitial.present(fromRootViewController: presenter)
        self.interstitial = nil
    }

    /// 共有シート閉鎖後に呼ぶ（未ロードなら短い遅延で再試行）
    func showAfterShare() {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(600))
            if interstitial != nil {
                showIfReady()
            } else {
                preload()
                try? await Task.sleep(for: .seconds(2))
                showIfReady()
            }
        }
    }

    private func topPresenter() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostPresented()
    }
}

private extension UIViewController {
    func topMostPresented() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostPresented()
        }
        if let navigation = self as? UINavigationController,
           let visible = navigation.visibleViewController {
            return visible.topMostPresented()
        }
        if let tab = self as? UITabBarController,
           let selected = tab.selectedViewController {
            return selected.topMostPresented()
        }
        return self
    }
}

extension InterstitialAdManager: GADFullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            interstitial = nil
            preload()
        }
    }

    nonisolated func ad(
        _ ad: GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        Task { @MainActor in
            interstitial = nil
            preload()
        }
    }
}
