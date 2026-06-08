import UIKit

/// 友達に格言をテキストで送る（個人間共有に特化）
@MainActor
enum InviteManager {
    private static let appStoreURL = "https://apps.apple.com/app/id6771264998"

    static func invite(quote: Quote?) {
        var text: String
        if let quote {
            text = """
            "\(quote.text)"

            このアプリ、なんか良い。
            \(appStoreURL)
            """
        } else {
            text = """
            毎日AIが紡ぐ「っぽい格言」、なんか良い。
            \(appStoreURL)
            """
        }

        ShareActivityPresenter.present(items: [text])
    }
}
