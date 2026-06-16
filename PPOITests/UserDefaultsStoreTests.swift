import XCTest
@testable import PPOI

// Phase 2: UserDefaultsStore → StreakTracker / RewardUnlocker / FavoritesStore に分割済み
// 各クラスのテストを同一ファイルで管理する

final class StreakTrackerTests: XCTestCase {
    private func makeTracker() -> (StreakTracker, UserDefaults) {
        let name = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return (StreakTracker(defaults: defaults), defaults)
    }

    private var jstCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return cal
    }

    private func dateString(daysAgo: Int) -> String {
        let date = jstCalendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        return DateFormatter.jstDate.string(from: date)
    }

    // MARK: - Streak: first visit

    func test_firstVisit_startsStreakAt1() {
        let (tracker, _) = makeTracker()
        tracker.registerTodayVisit()
        XCTAssertEqual(tracker.currentStreak, 1)
    }

    // MARK: - Streak: consecutive

    func test_consecutiveVisit_incrementsStreak() {
        let name = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        defaults.set(dateString(daysAgo: 1), forKey: "lastSeenDate")
        defaults.set(3, forKey: "currentStreak")

        let tracker = StreakTracker(defaults: defaults)
        tracker.registerTodayVisit()
        XCTAssertEqual(tracker.currentStreak, 4)
    }

    // MARK: - Streak: broken

    func test_gapInStreak_resetsTo1() {
        let name = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        defaults.set(dateString(daysAgo: 3), forKey: "lastSeenDate")
        defaults.set(10, forKey: "currentStreak")

        let tracker = StreakTracker(defaults: defaults)
        tracker.registerTodayVisit()
        XCTAssertEqual(tracker.currentStreak, 1)
    }

    // MARK: - Streak: same day idempotent

    func test_sameDayVisit_doesNotChangeStreak() {
        let (tracker, _) = makeTracker()
        tracker.registerTodayVisit()
        let streak = tracker.currentStreak
        tracker.registerTodayVisit()
        XCTAssertEqual(tracker.currentStreak, streak)
    }

    // MARK: - Streak: visitedDates populated

    func test_registerTodayVisit_addsToVisitedDates() {
        let (tracker, _) = makeTracker()
        let today = DateFormatter.jstDate.string(from: Date())
        tracker.registerTodayVisit()
        XCTAssertTrue(tracker.visitedDates.contains(today))
    }
}

final class RewardUnlockerTests: XCTestCase {
    private func makeUnlocker(defaults: UserDefaults? = nil) -> (RewardUnlocker, UserDefaults) {
        let name = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let d = defaults ?? {
            let ud = UserDefaults(suiteName: name)!
            ud.removePersistentDomain(forName: name)
            return ud
        }()
        return (RewardUnlocker(defaults: d), d)
    }

    private var jstCalendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return cal
    }

    private func dateString(daysAgo: Int) -> String {
        let date = jstCalendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        return DateFormatter.jstDate.string(from: date)
    }

    // MARK: - Rewards: 7-day streak unlocks theme

    func test_sevenDayStreak_unlocksTheme() {
        let name = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        defaults.set(6, forKey: "currentStreak")
        defaults.set(dateString(daysAgo: 1), forKey: "lastSeenDate")

        let tracker = StreakTracker(defaults: defaults)
        tracker.registerTodayVisit()

        let (unlocker, _) = makeUnlocker(defaults: defaults)
        let reward = unlocker.checkAndUnlockRewards(streak: tracker.currentStreak)

        XCTAssertEqual(reward, .streakTheme)
        XCTAssertTrue(unlocker.hasUnlockedStreakTheme)
    }

    // MARK: - Rewards: 30-day streak unlocks title

    func test_thirtyDayStreak_unlocksTitle() {
        let name = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        defaults.set(29, forKey: "currentStreak")
        defaults.set(dateString(daysAgo: 1), forKey: "lastSeenDate")
        defaults.set(true, forKey: "hasUnlockedStreakTheme")

        let tracker = StreakTracker(defaults: defaults)
        tracker.registerTodayVisit()

        let (unlocker, _) = makeUnlocker(defaults: defaults)
        let reward = unlocker.checkAndUnlockRewards(streak: tracker.currentStreak)

        XCTAssertEqual(reward, .masterTitle)
        XCTAssertTrue(unlocker.hasEarnedMasterTitle)
    }

    // MARK: - Rewards: idempotent

    func test_checkRewards_idempotent() {
        let (unlocker, defaults) = makeUnlocker()
        defaults.set(true, forKey: "hasUnlockedStreakTheme")

        let reward = unlocker.checkAndUnlockRewards(streak: 10)
        XCTAssertNil(reward)
    }
}

final class FavoritesStoreTests: XCTestCase {
    private func makeStore() -> FavoritesStore {
        let name = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return FavoritesStore(defaults: defaults)
    }

    // MARK: - Favorites: limit

    func test_favorites_cappedAt100() {
        let store = makeStore()
        for i in 0 ..< 110 {
            let q = Quote(id: "id\(i)", date: "2026-01-\(String(format: "%02d", (i % 28) + 1))", text: "テスト格言\(i)", tone: .serious)
            store.toggleFavorite(q)
        }
        XCTAssertLessThanOrEqual(store.list.count, 100)
    }

    // MARK: - Favorites: toggle add/remove

    func test_toggleFavorite_addsThenRemoves() {
        let store = makeStore()
        let q = Quote(id: "x", date: "2026-06-11", text: "テスト", tone: .serious)

        store.toggleFavorite(q)
        XCTAssertTrue(store.isFavorite(q))

        store.toggleFavorite(q)
        XCTAssertFalse(store.isFavorite(q))
    }
}
