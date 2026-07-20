import UIKit

/// 友達に格言をテキストで送る（個人間共有に特化）
@MainActor
enum InviteManager {
    private static let appStoreURL = AppLinks.appStoreURLString

    static func invite(quote: Quote?) {
        var text = if let quote {
            """
            "\(quote.text)"

            このアプリ、なんか良い。
            \(appStoreURL)
            """
        } else {
            """
            毎日AIが紡ぐ「っぽい格言」、なんか良い。
            \(appStoreURL)
            """
        }

        ShareActivityPresenter.present(items: [text])
    }
}
