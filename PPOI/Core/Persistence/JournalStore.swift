import Foundation

@Observable
final class JournalStore {
    private enum Key {
        static let entries = "journalEntries"
    }

    static let maxLength = 200

    private let defaults: UserDefaults
    private(set) var entries: [String: String] // [date: text]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        entries = Self.load(from: defaults)
    }

    func entry(for date: String) -> String {
        entries[date] ?? ""
    }

    func save(text: String, for date: String) {
        let trimmed = String(text.prefix(Self.maxLength))
        if trimmed.isEmpty {
            entries.removeValue(forKey: date)
        } else {
            entries[date] = trimmed
        }
        persist()
    }

    func journaledDates() -> Set<String> {
        Set(entries.keys)
    }

    var totalEntryCount: Int {
        entries.count
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: Key.entries)
        }
    }

    private static func load(from defaults: UserDefaults) -> [String: String] {
        guard let data = defaults.data(forKey: Key.entries),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return decoded
    }
}
