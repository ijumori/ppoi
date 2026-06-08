import Foundation
import WidgetKit

@MainActor
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
        } catch {
            quote = store.cachedQuote(for: DateFormatter.jstDate.string(from: Date())) ?? .placeholder
        }

        store.registerTodayVisit()
        syncWidget()
    }

    /// 取得済みの今日の格言を App Group へ書き出し、ウィジェットを更新する
    private func syncWidget() {
        guard let quote else { return }
        SharedQuoteStore.save(date: quote.date, text: quote.text)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
