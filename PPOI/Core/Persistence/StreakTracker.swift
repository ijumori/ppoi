import Foundation

@Observable
final class StreakTracker {
    private enum Key {
        static let currentStreak = "currentStreak"
        static let lastSeenDate = "lastSeenDate"
        static let visitedDates = "visitedDates"
        static let voteCount = "voteCount"
    }

    private let defaults: UserDefaults
    private(set) var currentStreak: Int
    private(set) var visitedDates: Set<String>
    private(set) var voteCount: Int

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        currentStreak = defaults.integer(forKey: Key.currentStreak)
        visitedDates = Self.loadVisitedDates(from: defaults)
        voteCount = defaults.integer(forKey: Key.voteCount)
    }

    /// 今日の閲覧を記録し、連続日数を更新する（同日複数回は不変）
    func registerTodayVisit() {
        let today = DateFormatter.jstDate.string(from: Date())
        let last = defaults.string(forKey: Key.lastSeenDate)

        visitedDates.insert(today)
        persistVisitedDates()

        if last == today {
            return
        }

        if let last, Self.isConsecutive(previous: last, today: today) {
            currentStreak += 1
        } else {
            currentStreak = 1
        }

        defaults.set(today, forKey: Key.lastSeenDate)
        defaults.set(currentStreak, forKey: Key.currentStreak)
    }

    func recordVote() {
        voteCount += 1
        defaults.set(voteCount, forKey: Key.voteCount)
    }

    private func persistVisitedDates() {
        do {
            let data = try JSONEncoder().encode(Array(visitedDates))
            defaults.set(data, forKey: Key.visitedDates)
        } catch {
            SecureLogger.error("visitedDates persist failed: \(error)", category: .general)
        }
    }

    private static func loadVisitedDates(from defaults: UserDefaults) -> Set<String> {
        guard let data = defaults.data(forKey: Key.visitedDates),
              let array = try? JSONDecoder().decode([String].self, from: data)
        else { return [] }
        return Set(array)
    }

    /// previous の翌日が today なら連続とみなす（JST 基準）
    static func isConsecutive(previous: String, today: String) -> Bool {
        guard let previousDate = DateFormatter.jstDate.date(from: previous) else { return false }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        guard let nextDate = calendar.date(byAdding: .day, value: 1, to: previousDate) else { return false }
        return DateFormatter.jstDate.string(from: nextDate) == today
    }
}
