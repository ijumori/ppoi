import Foundation

/// アプリ内で参照する固定 URL の単一ソース。
/// リテラルはここでのみ定義し、`URL(string:)!` の強制アンラップもこの1箇所に閉じ込める
/// （すべてコンパイル時に確定する妥当な URL のため失敗しない）。
enum AppLinks {
    static let appStoreID = "6771264998"

    static let appStore = URL(string: "https://apps.apple.com/app/id\(appStoreID)")!
    static let privacyPolicy = URL(string: "https://ijumori.github.io/ppoi/legal/privacy-policy.html")!
    static let termsOfUse = URL(string: "https://ijumori.github.io/ppoi/legal/terms-of-use.html")!

    /// 共有テキスト・QR など文字列として使う場合の App Store URL
    static var appStoreURLString: String {
        appStore.absoluteString
    }
}
