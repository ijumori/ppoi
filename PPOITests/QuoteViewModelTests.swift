import XCTest
@testable import PPOI

private struct MockRepository: QuoteRepository {
    var result: Result<Quote, Error>

    func fetchQuote(for date: String) async throws -> Quote {
        try result.get()
    }
}

@MainActor
final class QuoteViewModelTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        KeychainStore.delete(.quoteCache)
    }

    // MARK: - Success

    func test_loadQuote_success_setsQuote() async {
        let expected = Quote(id: "2026-06-11", date: "2026-06-11", text: "テスト格言", tone: .serious)
        let service = QuoteService(
            repository: MockRepository(result: .success(expected))
        )
        let vm = QuoteViewModel(quoteService: service)

        await vm.loadQuote()

        XCTAssertNotNil(vm.quote)
        XCTAssertEqual(vm.quote?.text, "テスト格言")
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Failure falls back to cached or placeholder

    func test_loadQuote_failure_fallsBackToPlaceholder() async {
        let service = QuoteService(
            repository: MockRepository(result: .failure(QuoteRepositoryError.firebaseNotConfigured))
        )
        let vm = QuoteViewModel(quoteService: service)

        await vm.loadQuote()

        XCTAssertNotNil(vm.quote)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - isLoading resets after load

    func test_loadQuote_isLoadingReset() async {
        let service = QuoteService(
            repository: MockRepository(result: .success(
                Quote(id: "x", date: "2026-06-11", text: "格言", tone: .humorous)
            ))
        )
        let vm = QuoteViewModel(quoteService: service)

        await vm.loadQuote()
        XCTAssertFalse(vm.isLoading)
    }
}
