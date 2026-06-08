import Foundation

@Observable
final class UserDefaultsStore {
    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedTheme = "selectedTheme"
        static let notificationEnabled = "notificationEnabled"
        static let notificationHour = "notificationHour"
        static let fontVariant = "fontVariant"
        static let favorites = "favorites"
        static let currentStreak = "currentStreak"
        static let lastSeenDate = "lastSeenDate"
        static let totalShareCount = "totalShareCount"
        static let lastReviewPromptDate = "lastReviewPromptDate"
        static let hasUnlockedStreakTheme = "hasUnlockedStreakTheme"
        static let hasEarnedMasterTitle = "hasEarnedMasterTitle"
    }

    /// お気に入り保存件数の上限（UserDefaults 肥大化防止）
    private static let favoritesLimit = 100

    private let defaults: UserDefaults

    /// お気に入り格言（新しい順）。UI 連動のため stored プロパティで保持
    private(set) var favorites: [Quote]

    /// 連続閲覧日数
    private(set) var currentStreak: Int

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        SecureQuoteCache.clearLegacyUserDefaults(defaults)
        favorites = Self.loadFavorites(from: defaults)
        currentStreak = defaults.integer(forKey: Key.currentStreak)
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
        SecureQuoteCache.save(quote)
    }

    func cachedQuote(for date: String) -> Quote? {
        SecureQuoteCache.load(for: date)
    }

    // MARK: - シェア回数

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

    // MARK: - お気に入り（ローカルのみ）

    func isFavorite(_ quote: Quote) -> Bool {
        favorites.contains { $0.id == quote.id }
    }

    func toggleFavorite(_ quote: Quote) {
        if let index = favorites.firstIndex(where: { $0.id == quote.id }) {
            favorites.remove(at: index)
        } else {
            favorites.insert(quote, at: 0)
            if favorites.count > Self.favoritesLimit {
                favorites = Array(favorites.prefix(Self.favoritesLimit))
            }
        }
        persistFavorites()
    }

    func removeFavorites(at offsets: IndexSet) {
        favorites.remove(atOffsets: offsets)
        persistFavorites()
    }

    private func persistFavorites() {
        let data = try? JSONEncoder().encode(favorites)
        defaults.set(data, forKey: Key.favorites)
    }

    private static func loadFavorites(from defaults: UserDefaults) -> [Quote] {
        guard let data = defaults.data(forKey: Key.favorites),
              let list = try? JSONDecoder().decode([Quote].self, from: data)
        else { return [] }
        return list
    }

    // MARK: - ストリーク報酬

    /// 7日連続で禅・ゴールドテーマ解放（一度解放したら永続）
    var hasUnlockedStreakTheme: Bool {
        get { defaults.bool(forKey: Key.hasUnlockedStreakTheme) }
        set { defaults.set(newValue, forKey: Key.hasUnlockedStreakTheme) }
    }

    /// 30日連続で「格言マスター」称号獲得（永続）
    var hasEarnedMasterTitle: Bool {
        get { defaults.bool(forKey: Key.hasEarnedMasterTitle) }
        set { defaults.set(newValue, forKey: Key.hasEarnedMasterTitle) }
    }

    /// ストリーク達成に応じて報酬を解放し、新規解放があれば true を返す
    @discardableResult
    func checkAndUnlockStreakRewards() -> StreakReward? {
        if currentStreak >= 30, !hasEarnedMasterTitle {
            hasEarnedMasterTitle = true
            if !hasUnlockedStreakTheme { hasUnlockedStreakTheme = true }
            return .masterTitle
        }
        if currentStreak >= 7, !hasUnlockedStreakTheme {
            hasUnlockedStreakTheme = true
            return .streakTheme
        }
        return nil
    }

    // MARK: - ストリーク（連続閲覧日数）

    /// 今日の閲覧を記録し、連続日数を更新する（同日複数回は不変）
    func registerTodayVisit() {
        let today = DateFormatter.jstDate.string(from: Date())
        let last = defaults.string(forKey: Key.lastSeenDate)

        if last == today { return }

        if let last, Self.isConsecutive(previous: last, today: today) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        defaults.set(today, forKey: Key.lastSeenDate)
        defaults.set(currentStreak, forKey: Key.currentStreak)
    }

    /// previous の翌日が today なら連続とみなす（JST 基準）
    private static func isConsecutive(previous: String, today: String) -> Bool {
        guard let previousDate = DateFormatter.jstDate.date(from: previous) else { return false }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: previousDate) else { return false }
        return DateFormatter.jstDate.string(from: nextDate) == today
    }
}

enum StreakReward {
    /// 7日連続 → 禅・ゴールドテーマ解放
    case streakTheme
    /// 30日連続 → 格言マスター称号
    case masterTitle
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
