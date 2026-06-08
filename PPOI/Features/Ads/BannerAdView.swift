import GoogleMobileAds
import SwiftUI
import UIKit

struct BannerAdView: View {
    @Environment(StoreManager.self) private var store

    var body: some View {
        if store.isPurchased {
            EmptyView()
        } else {
            VStack(spacing: 0) {
                #if DEBUG
                if AdMobCompliance.isTestMode {
                    Text("TEST AD — クリック禁止（開発用）")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                }
                #endif

                BannerAdRepresentable()
                    .frame(height: 50)
            }
        }
    }
}

private struct BannerAdRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        AdMobCompliance.assertSafeConfiguration()

        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = AdMobConfig.bannerUnitID
        banner.rootViewController = UIApplication.shared.topViewController
        banner.load(AdMobConfig.makeAdRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        uiView.rootViewController = UIApplication.shared.topViewController
    }
}

extension UIApplication {
    var topViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
}

private extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let navigation = self as? UINavigationController, let visible = navigation.visibleViewController {
            return visible.topMostViewController()
        }
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected.topMostViewController()
        }
        return self
    }
}
