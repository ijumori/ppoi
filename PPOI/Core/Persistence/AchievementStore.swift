import Foundation

@Observable
final class AchievementStore {
    private enum Key {
        static let unlocked = "unlockedAchievements"
        static let exploreViewCount = "exploreViewCount"
    }

    private let defaults: UserDefaults
    private(set) var unlocked: Set<Achievement>
    private(set) var exploreViewCount: Int

    /// 新規解放された実績（セレブレーション表示用）
    private(set) var newlyUnlocked: Achievement?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        unlocked = Self.loadUnlocked(from: defaults)
        exploreViewCount = defaults.integer(forKey: Key.exploreViewCount)
    }

    func isUnlocked(_ achievement: Achievement) -> Bool {
        unlocked.contains(achievement)
    }

    /// 実績解除チェック。新たに解除された場合は newlyUnlocked にセット。
    @discardableResult
    func check(
        preferences: UserPreferencesStore,
        favorites: FavoritesStore,
        streak: StreakTracker,
        rewards: RewardUnlocker,
        journalStore: JournalStore
    ) -> Achievement? {
        for achievement in Achievement.allCases {
            guard !unlocked.contains(achievement) else { continue }
            if shouldUnlock(achievement, preferences: preferences, favorites: favorites, streak: streak, rewards: rewards, journalStore: journalStore) {
                unlock(achievement)
                return achievement
            }
        }
        return nil
    }

    func incrementExploreView() {
        exploreViewCount += 1
        defaults.set(exploreViewCount, forKey: Key.exploreViewCount)
    }

    func clearNewlyUnlocked() {
        newlyUnlocked = nil
    }

    private func unlock(_ achievement: Achievement) {
        unlocked.insert(achievement)
        newlyUnlocked = achievement
        persist()
    }

    private func shouldUnlock(
        _ a: Achievement,
        preferences: UserPreferencesStore,
        favorites: FavoritesStore,
        streak: StreakTracker,
        rewards: RewardUnlocker,
        journalStore: JournalStore
    ) -> Bool {
        switch a {
        case .streakTheme: rewards.hasUnlockedStreakTheme
        case .masterTitle: rewards.hasEarnedMasterTitle
        case .firstFavorite: !favorites.list.isEmpty
        case .firstShare: preferences.totalShareCount >= 1
        case .firstJournal: journalStore.totalEntryCount >= 1
        case .explorer: exploreViewCount >= 10
        case .voter7: streak.voteCount >= 7
        case .sharer5: preferences.totalShareCount >= 5
        }
    }

    private func persist() {
        let rawValues = unlocked.map(\.rawValue)
        if let data = try? JSONEncoder().encode(rawValues) {
            defaults.set(data, forKey: Key.unlocked)
        }
    }

    private static func loadUnlocked(from defaults: UserDefaults) -> Set<Achievement> {
        guard let data = defaults.data(forKey: Key.unlocked),
              let rawValues = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return Set(rawValues.compactMap { Achievement(rawValue: $0) })
    }
}
