import Foundation

@Observable
final class FavoritesStore {
    private enum Key {
        static let favorites = "favorites"
    }

    /// 無料ユーザーの保存上限
    static let freeLimit = 10
    /// プレミアムユーザーの保存上限（実質無制限、UserDefaults肥大防止のキャップ）
    static let premiumLimit = 1000

    enum ToggleResult: Equatable {
        case added
        case removed
        case limitReached(limit: Int, isPremium: Bool)
    }

    private let defaults: UserDefaults
    private(set) var list: [Quote]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        list = Self.load(from: defaults)
    }

    func isFavorite(_ quote: Quote) -> Bool {
        list.contains { $0.id == quote.id }
    }

    @discardableResult
    func toggleFavorite(_ quote: Quote, isPremium: Bool) -> ToggleResult {
        if let index = list.firstIndex(where: { $0.id == quote.id }) {
            list.remove(at: index)
            persist()
            return .removed
        }
        let limit = isPremium ? Self.premiumLimit : Self.freeLimit
        if list.count >= limit {
            return .limitReached(limit: limit, isPremium: isPremium)
        }
        list.insert(quote, at: 0)
        persist()
        return .added
    }

    func remove(at offsets: IndexSet) {
        list.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(list)
            defaults.set(data, forKey: Key.favorites)
        } catch {
            SecureLogger.error("favorites persist failed: \(error)", category: .general)
        }
    }

    private static func load(from defaults: UserDefaults) -> [Quote] {
        guard let data = defaults.data(forKey: Key.favorites),
              let items = try? JSONDecoder().decode([Quote].self, from: data)
        else { return [] }
        return items
    }
}
