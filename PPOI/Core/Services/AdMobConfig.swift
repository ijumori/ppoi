import Foundation
import GoogleMobileAds

enum AdMobConfig {
    /// Google 公式デモ広告 ID（アカウントに紐づかない — クリックしても無効トラフィックにならない）
    /// https://developers.google.com/admob/ios/test-ads
    enum DemoIDs {
        static let app = "ca-app-pub-3940256099942544~1458002511"
        static let banner = "ca-app-pub-3940256099942544/2934735716"
        static let interstitial = "ca-app-pub-3940256099942544/4411468910"
    }

    private static let production: [String: String] = {
        guard let url = Bundle.main.url(forResource: "AdMobConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String]
        else { return [:] }
        return plist
    }()

    /// DEBUG では常に true
    static var usesTestAdUnits: Bool {
        AdMobCompliance.mustUseTestAds
    }

    static var appID: String {
        if usesTestAdUnits { return DemoIDs.app }
        return production["AdMobAppID"] ?? DemoIDs.app
    }

    static var bannerUnitID: String {
        if usesTestAdUnits { return DemoIDs.banner }
        return production["BannerAdUnitID"] ?? DemoIDs.banner
    }

    static var interstitialUnitID: String {
        if usesTestAdUnits { return DemoIDs.interstitial }
        return production["InterstitialAdUnitID"] ?? DemoIDs.interstitial
    }

    static var isProductionConfigured: Bool {
        guard let app = production["AdMobAppID"],
              let banner = production["BannerAdUnitID"],
              let interstitial = production["InterstitialAdUnitID"],
              !app.contains("XXXX"), !banner.contains("XXXX"), !interstitial.contains("XXXX")
        else { return false }
        return true
    }

    static func makeAdRequest() -> GADRequest {
        GADRequest()
    }
}
