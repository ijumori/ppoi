import Foundation
import GoogleMobileAds
import UIKit

/// AdMob ポリシー準拠 — 無効トラフィック防止
/// https://support.google.com/admob/answer/3342099
enum AdMobCompliance {
    /// DEBUG / シミュレータでは常に true（本番ユニットを使わない）
    static var mustUseTestAds: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// 現在テスト広告モードか
    static var isTestMode: Bool {
        mustUseTestAds || AdMobConfig.usesTestAdUnits
    }

    /// SDK 初期化時に呼ぶ（テストデバイス登録）
    static func configureForLaunch() {
        #if DEBUG
        var testDevices: [String] = []
        #if targetEnvironment(simulator)
        testDevices.append(GADSimulatorID)
        #else
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            testDevices.append(deviceID)
        }
        #endif
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = testDevices

        SecureLogger.info("AdMob TEST MODE active — test ad units only", category: .ads)
        #endif
    }

    /// 本番広告が読み込まれそうな場合に警告
    static func assertSafeConfiguration() {
        #if DEBUG
        if !AdMobConfig.usesTestAdUnits {
            assertionFailure("DEBUG ビルドで本番広告ユニットが使われています。AdMobConfig を確認してください。")
        }
        #endif
    }
}
