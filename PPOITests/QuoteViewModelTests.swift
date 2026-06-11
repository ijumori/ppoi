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

    private func makeDefaults() -> UserDefaults {
        let name = "com.takahiro.ppoi.tests.\(UUID().uuidString)"
        let d = UserDefaults(suiteName: name)!
        d.removePersistentDomain(forName: name)
        return d
    }

    // MARK: - Success

    func test_loadQuote_success_setsQuote() async {
        let expected = Quote(id: "2026-06-11", date: "2026-06-11", text: "テスト格言", tone: .serious)
        let service = QuoteService(
            repository: MockRepository(result: .success(expected)),
            store: UserDefaultsStore(defaults: makeDefaults())
        )
        let vm = QuoteViewModel(quoteService: service)
        let store = UserDefaultsStore(defaults: makeDefaults())

        await vm.loadQuote(store: store)

        XCTAssertNotNil(vm.quote)
        XCTAssertEqual(vm.quote?.text, "テスト格言")
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Failure falls back to cached or placeholder

    func test_loadQuote_failure_fallsBackToPlaceholder() async {
        let service = QuoteService(
            repository: MockRepository(result: .failure(QuoteRepositoryError.firebaseNotConfigured)),
            store: UserDefaultsStore(defaults: makeDefaults())
        )
        let vm = QuoteViewModel(quoteService: service)
        let store = UserDefaultsStore(defaults: makeDefaults())

        await vm.loadQuote(store: store)

        XCTAssertNotNil(vm.quote)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - isLoading resets after load

    func test_loadQuote_isLoadingReset() async {
        let service = QuoteService(
            repository: MockRepository(result: .success(
                Quote(id: "x", date: "2026-06-11", text: "格言", tone: .humorous)
            )),
            store: UserDefaultsStore(defaults: makeDefaults())
        )
        let vm = QuoteViewModel(quoteService: service)

        await vm.loadQuote(store: UserDefaultsStore(defaults: makeDefaults()))
        XCTAssertFalse(vm.isLoading)
    }
}
