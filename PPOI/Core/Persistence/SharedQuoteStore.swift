import Foundation

/// App Group 経由でアプリとウィジェットが共有する「今日の格言」ストア。
/// 格言は全ユーザー公開コンテンツのため平文で保持する（私的データは保存しない）。
enum SharedQuoteStore {
    static let appGroupID = "group.com.takahiro.ppoi"
    private static let key = "todayQuote"

    struct Snapshot: Codable {
        let date: String
        let text: String
    }

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func save(date: String, text: String) {
        guard let defaults,
              let data = try? JSONEncoder().encode(Snapshot(date: date, text: text))
        else { return }
        defaults.set(data, forKey: key)
    }

    static func load() -> Snapshot? {
        guard let defaults,
              let data = defaults.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data)
        else { return nil }
        return snapshot
    }
}
