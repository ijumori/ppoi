import Foundation

final class QuoteService {
    private let repository: QuoteRepository
    private let store: UserDefaultsStore

    init(
        repository: QuoteRepository = FirestoreQuoteRepository(),
        store: UserDefaultsStore = UserDefaultsStore()
    ) {
        self.repository = repository
        self.store = store
    }

    func fetchTodayQuote() async throws -> Quote {
        let today = DateFormatter.jstDate.string(from: Date())

        if let cached = store.cachedQuote(for: today) {
            return cached
        }

        do {
            let quote = try await repository.fetchQuote(for: today)
            store.cacheQuote(quote)
            return quote
        } catch QuoteRepositoryError.firebaseNotConfigured {
            return fallbackQuote(for: today)
        } catch QuoteRepositoryError.documentNotFound {
            return fallbackQuote(for: today)
        }
    }

    private func fallbackQuote(for date: String) -> Quote {
        Quote(
            id: date,
            date: date,
            text: Quote.placeholder.text,
            tone: Quote.placeholder.tone
        )
    }
}
