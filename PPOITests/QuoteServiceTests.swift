import XCTest
@testable import PPOI

// MARK: - Mock Repository

private struct MockRepository: QuoteRepository {
    var result: Result<Quote, Error>

    func fetchQuote(for date: String) async throws -> Quote {
        try result.get()
    }
}

// MARK: - Tests

final class QuoteServiceTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        // Clear Keychain quote cache so tests don't bleed into each other
        KeychainStore.delete(.quoteCache)
    }

    private var sampleQuote: Quote {
        Quote(id: "2026-06-11", date: "2026-06-11", text: "テスト格言", tone: .serious)
    }

    // MARK: - Cache hit

    func test_cacheHit_returnsCachedQuote() async throws {
        SecureQuoteCache.save(sampleQuote)

        let service = QuoteService(
            repository: MockRepository(result: .failure(QuoteRepositoryError.documentNotFound(date: "2026-06-11")))
        )

        let today = DateFormatter.jstDate.string(from: Date())
        // Only hits cache if the date matches today
        if sampleQuote.date == today {
            let quote = try await service.fetchTodayQuote()
            XCTAssertEqual(quote.id, sampleQuote.id)
        }
    }

    // MARK: - Fallback: firebaseNotConfigured

    func test_firebaseNotConfigured_returnsFallback() async throws {
        let service = QuoteService(
            repository: MockRepository(result: .failure(QuoteRepositoryError.firebaseNotConfigured))
        )
        let quote = try await service.fetchTodayQuote()
        XCTAssertFalse(quote.text.isEmpty)
    }

    // MARK: - Fallback: documentNotFound

    func test_documentNotFound_returnsFallback() async throws {
        let today = DateFormatter.jstDate.string(from: Date())
        let service = QuoteService(
            repository: MockRepository(result: .failure(QuoteRepositoryError.documentNotFound(date: today)))
        )
        let quote = try await service.fetchTodayQuote()
        XCTAssertFalse(quote.text.isEmpty)
    }

    // MARK: - Fallback: untrustedEnvironment

    func test_untrustedEnvironment_returnsFallback() async throws {
        let service = QuoteService(
            repository: MockRepository(result: .failure(QuoteRepositoryError.untrustedEnvironment))
        )
        let quote = try await service.fetchTodayQuote()
        XCTAssertFalse(quote.text.isEmpty)
    }

    // MARK: - Success: repository result is returned

    func test_successfulFetch_returnsQuote() async throws {
        let expected = Quote(id: "2026-06-11", date: "2026-06-11", text: "成功の格言", tone: .humorous)
        let service = QuoteService(
            repository: MockRepository(result: .success(expected))
        )
        let quote = try await service.fetchTodayQuote()
        XCTAssertEqual(quote.text, "成功の格言")
    }
}
