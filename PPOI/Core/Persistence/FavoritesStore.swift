import Foundation

@Observable
final class FavoritesStore {
    private enum Key {
        static let favorites = "favorites"
    }

    private static let limit = 100

    private let defaults: UserDefaults
    private(set) var list: [Quote]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        list = Self.load(from: defaults)
    }

    func isFavorite(_ quote: Quote) -> Bool {
        list.contains { $0.id == quote.id }
    }

    func toggleFavorite(_ quote: Quote) {
        if let index = list.firstIndex(where: { $0.id == quote.id }) {
            list.remove(at: index)
        } else {
            list.insert(quote, at: 0)
            if list.count > Self.limit {
                list = Array(list.prefix(Self.limit))
            }
        }
        persist()
    }

    func remove(at offsets: IndexSet) {
        list.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        let data = try? JSONEncoder().encode(list)
        defaults.set(data, forKey: Key.favorites)
    }

    private static func load(from defaults: UserDefaults) -> [Quote] {
        guard let data = defaults.data(forKey: Key.favorites),
              let items = try? JSONDecoder().decode([Quote].self, from: data)
        else { return [] }
        return items
    }
}
