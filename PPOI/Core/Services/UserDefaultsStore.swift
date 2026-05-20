import Foundation

@Observable
final class UserDefaultsStore {
    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedTheme = "selectedTheme"
        static let notificationEnabled = "notificationEnabled"
        static let notificationHour = "notificationHour"
        static let fontVariant = "fontVariant"
        static let cachedQuoteDate = "cachedQuoteDate"
        static let cachedQuoteText = "cachedQuoteText"
        static let cachedQuoteTone = "cachedQuoteTone"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding) }
    }

    var selectedTheme: AppTheme {
        get {
            AppTheme(rawValue: defaults.string(forKey: Key.selectedTheme) ?? "") ?? .darkPremium
        }
        set { defaults.set(newValue.rawValue, forKey: Key.selectedTheme) }
    }

    var notificationEnabled: Bool {
        get {
            if defaults.object(forKey: Key.notificationEnabled) == nil { return true }
            return defaults.bool(forKey: Key.notificationEnabled)
        }
        set { defaults.set(newValue, forKey: Key.notificationEnabled) }
    }

    var notificationHour: Int {
        get {
            let value = defaults.integer(forKey: Key.notificationHour)
            return value == 0 && defaults.object(forKey: Key.notificationHour) == nil ? 12 : value
        }
        set { defaults.set(newValue, forKey: Key.notificationHour) }
    }

    var fontVariant: FontVariant {
        get {
            FontVariant(rawValue: defaults.string(forKey: Key.fontVariant) ?? "") ?? .serif
        }
        set { defaults.set(newValue.rawValue, forKey: Key.fontVariant) }
    }

    func cacheQuote(_ quote: Quote) {
        defaults.set(quote.date, forKey: Key.cachedQuoteDate)
        defaults.set(quote.text, forKey: Key.cachedQuoteText)
        defaults.set(quote.tone.rawValue, forKey: Key.cachedQuoteTone)
    }

    func cachedQuote(for date: String) -> Quote? {
        guard defaults.string(forKey: Key.cachedQuoteDate) == date,
              let text = defaults.string(forKey: Key.cachedQuoteText),
              let toneRaw = defaults.string(forKey: Key.cachedQuoteTone),
              let tone = QuoteTone(rawValue: toneRaw)
        else { return nil }

        return Quote(id: date, date: date, text: text, tone: tone)
    }
}

enum FontVariant: String, CaseIterable, Identifiable {
    case serif
    case `default`

    var id: String { rawValue }

    var label: String {
        switch self {
        case .serif: "カチッと（明朝）"
        case .default: "ゆるめ（ゴシック）"
        }
    }
}
