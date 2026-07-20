import Foundation

/// アプリ内で繰り返し使う固定文言の単一ソース。
/// 複数ファイルにハードコードされていた表示文言・ハッシュタグをここに集約する。
/// （現時点では日本語のみ。将来ローカライズするなら String Catalog へ移す。）
enum AppStrings {
    /// 格言のクレジット表記
    static let creativeQuoteCredit = "AIが紡ぐ創作格言"
    /// 一句の儚さを示すサブコピー
    static let ephemeralTagline = "明日には消える一句"
    /// 共有・投稿用ハッシュタグ
    static let hashtag = "#っぽい格言"
}
