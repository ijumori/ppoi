import Foundation

enum StreakReward {
    /// 7日連続 → 禅・ゴールドテーマ解放
    case streakTheme
    /// 30日連続 → 格言マスター称号
    case masterTitle

    /// 禅・ゴールドテーマ解放に必要な連続日数
    static let streakThemeDays = 7
    /// 格言マスター称号に必要な連続日数
    static let masterTitleDays = 30
}

@Observable
final class RewardUnlocker {
    private enum Key {
        static let hasUnlockedStreakTheme = "hasUnlockedStreakTheme"
        static let hasEarnedMasterTitle = "hasEarnedMasterTitle"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasUnlockedStreakTheme: Bool {
        get { defaults.bool(forKey: Key.hasUnlockedStreakTheme) }
        set { defaults.set(newValue, forKey: Key.hasUnlockedStreakTheme) }
    }

    var hasEarnedMasterTitle: Bool {
        get { defaults.bool(forKey: Key.hasEarnedMasterTitle) }
        set { defaults.set(newValue, forKey: Key.hasEarnedMasterTitle) }
    }

    /// ストリーク達成に応じて報酬を解放し、新規解放があれば返す
    @discardableResult
    func checkAndUnlockRewards(streak: Int) -> StreakReward? {
        if streak >= StreakReward.masterTitleDays, !hasEarnedMasterTitle {
            hasEarnedMasterTitle = true
            if !hasUnlockedStreakTheme {
                hasUnlockedStreakTheme = true
            }
            return .masterTitle
        }
        if streak >= StreakReward.streakThemeDays, !hasUnlockedStreakTheme {
            hasUnlockedStreakTheme = true
            return .streakTheme
        }
        return nil
    }
}
