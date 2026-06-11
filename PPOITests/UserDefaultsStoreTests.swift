import XCTest
@testable import PPOI

final class UserDefaultsStoreTests: XCTestCase {
    // MARK: - Helpers

    private func makeStore(suiteName: String? = nil) -> (UserDefaultsStore, UserDefaults) {
        let name = suiteName ?? "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        let store = UserDefaultsStore(defaults: defaults)
        return (store, defaults)
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
        let (store, _) = makeStore()
        store.registerTodayVisit()
        XCTAssertEqual(store.currentStreak, 1)
    }

    // MARK: - Streak: consecutive

    func test_consecutiveVisit_incrementsStreak() {
        let suiteName = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(dateString(daysAgo: 1), forKey: "lastSeenDate")
        defaults.set(3, forKey: "currentStreak")

        let store = UserDefaultsStore(defaults: defaults)
        store.registerTodayVisit()

        XCTAssertEqual(store.currentStreak, 4)
    }

    // MARK: - Streak: broken

    func test_gapInStreak_resetsTo1() {
        let suiteName = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(dateString(daysAgo: 3), forKey: "lastSeenDate")
        defaults.set(10, forKey: "currentStreak")

        let store = UserDefaultsStore(defaults: defaults)
        store.registerTodayVisit()

        XCTAssertEqual(store.currentStreak, 1)
    }

    // MARK: - Streak: same day idempotent

    func test_sameDayVisit_doesNotChangeStreak() {
        let (store, _) = makeStore()
        store.registerTodayVisit()
        let streak = store.currentStreak
        store.registerTodayVisit()
        XCTAssertEqual(store.currentStreak, streak)
    }

    // MARK: - Streak: visitedDates populated

    func test_registerTodayVisit_addsToVisitedDates() {
        let (store, _) = makeStore()
        let today = DateFormatter.jstDate.string(from: Date())
        store.registerTodayVisit()
        XCTAssertTrue(store.visitedDates.contains(today))
    }

    // MARK: - Rewards: 7-day streak unlocks theme

    func test_sevenDayStreak_unlocksTheme() {
        let suiteName = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(6, forKey: "currentStreak")
        defaults.set(dateString(daysAgo: 1), forKey: "lastSeenDate")

        let store = UserDefaultsStore(defaults: defaults)
        store.registerTodayVisit()
        let reward = store.checkAndUnlockStreakRewards()

        XCTAssertEqual(reward, .streakTheme)
        XCTAssertTrue(store.hasUnlockedStreakTheme)
    }

    // MARK: - Rewards: 30-day streak unlocks title

    func test_thirtyDayStreak_unlocksTitle() {
        let suiteName = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(29, forKey: "currentStreak")
        defaults.set(dateString(daysAgo: 1), forKey: "lastSeenDate")
        defaults.set(true, forKey: "hasUnlockedStreakTheme")

        let store = UserDefaultsStore(defaults: defaults)
        store.registerTodayVisit()
        let reward = store.checkAndUnlockStreakRewards()

        XCTAssertEqual(reward, .masterTitle)
        XCTAssertTrue(store.hasEarnedMasterTitle)
    }

    // MARK: - Rewards: idempotent

    func test_checkRewards_idempotent() {
        let suiteName = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(10, forKey: "currentStreak")
        defaults.set(true, forKey: "hasUnlockedStreakTheme")

        let store = UserDefaultsStore(defaults: defaults)
        let reward = store.checkAndUnlockStreakRewards()

        XCTAssertNil(reward)
    }

    // MARK: - Favorites: limit

    func test_favorites_cappedAt100() {
        let (store, _) = makeStore()
        for i in 0 ..< 110 {
            let q = Quote(id: "id\(i)", date: "2026-01-\(String(format: "%02d", (i % 28) + 1))", text: "テスト格言\(i)", tone: .serious)
            store.toggleFavorite(q)
        }
        XCTAssertLessThanOrEqual(store.favorites.count, 100)
    }

    // MARK: - Favorites: toggle add/remove

    func test_toggleFavorite_addsThenRemoves() {
        let (store, _) = makeStore()
        let q = Quote(id: "x", date: "2026-06-11", text: "テスト", tone: .serious)

        store.toggleFavorite(q)
        XCTAssertTrue(store.isFavorite(q))

        store.toggleFavorite(q)
        XCTAssertFalse(store.isFavorite(q))
    }
}
