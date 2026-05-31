import Foundation

@Observable
final class QuoteViewModel {
    var quote: Quote?
    var isLoading = false
    var showShareSheet = false
    var showSettings = false
    var appeared = false

    private let quoteService = QuoteService()

    func loadQuote(store: UserDefaultsStore) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await quoteService.fetchTodayQuote()
            quote = fetched
            store.cacheQuote(fetched)
        } catch {
            quote = store.cachedQuote(for: DateFormatter.jstDate.string(from: Date())) ?? .placeholder
        }

        store.registerTodayVisit()
    }
}
