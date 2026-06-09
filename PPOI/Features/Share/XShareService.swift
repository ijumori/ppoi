import UIKit

@MainActor
enum XShareService {
    private static let appStoreURL = "https://apps.apple.com/app/id6771264998"

    static func shareToX(text: String, image: UIImage? = nil) {
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text

        // 1. Try Twitter app URL scheme
        if let twitterURL = URL(string: "twitter://post?message=\(encodedText)"),
           UIApplication.shared.canOpenURL(twitterURL) {
            UIApplication.shared.open(twitterURL)
            return
        }

        // 2. Fallback to X web intent
        if let webURL = URL(string: "https://x.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(webURL)
            return
        }

        // 3. Final fallback: UIActivityViewController
        var items: [Any] = [text]
        if let image { items.append(image) }
        ShareActivityPresenter.present(items: items)
    }

    static func buildShareText(quote: Quote, reflection: String = "") -> String {
        let trimmed = reflection.trimmingCharacters(in: .whitespacesAndNewlines)
        var text = ""
        if !trimmed.isEmpty {
            text += "私の考察：\(trimmed)\n\n"
        }
        let maxLength = 100
        let quoteText = quote.text.count > maxLength
            ? String(quote.text.prefix(maxLength)) + "…"
            : quote.text
        text += "「\(quoteText)」\n\n#っぽい格言\n\(appStoreURL)"
        return text
    }
}
