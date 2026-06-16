import Foundation

@Observable
final class UserPreferencesStore {
    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedTheme = "selectedTheme"
        static let notificationEnabled = "notificationEnabled"
        static let notificationHour = "notificationHour"
        static let fontVariant = "fontVariant"
        static let totalShareCount = "totalShareCount"
        static let lastReviewPromptDate = "lastReviewPromptDate"
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
        get { AppTheme(rawValue: defaults.string(forKey: Key.selectedTheme) ?? "") ?? .darkPremium }
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
        get { FontVariant(rawValue: defaults.string(forKey: Key.fontVariant) ?? "") ?? .serif }
        set { defaults.set(newValue.rawValue, forKey: Key.fontVariant) }
    }

    var totalShareCount: Int {
        get { defaults.integer(forKey: Key.totalShareCount) }
        set { defaults.set(newValue, forKey: Key.totalShareCount) }
    }

    func recordShare() {
        totalShareCount += 1
    }

    var lastReviewPromptDate: String? {
        get { defaults.string(forKey: Key.lastReviewPromptDate) }
        set { defaults.set(newValue, forKey: Key.lastReviewPromptDate) }
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
