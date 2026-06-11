import Foundation
import StoreKit

/// 買い切り（非消費型）課金の単一の真実源。StoreKit 2 を使用。
@MainActor
@Observable
final class StoreManager {
    static let shared = StoreManager()

    /// 非消費型プロダクト ID（広告除去 + 全機能解放）
    static let premiumProductID = "com.takahiro.ppoi.premium"

    private(set) var product: Product?
    private(set) var isPurchased = false
    private(set) var isLoading = false
    var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    private init() {}

    /// アプリ起動時に1回だけ呼ぶ（トランザクション購読 + 状態復元）
    func start() {
        guard updatesTask == nil else { return }
        updatesTask = listenForTransactions()
        Task {
            await loadProducts()
            await refreshPurchasedState()
        }
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [Self.premiumProductID])
            product = products.first
        } catch {
            errorMessage = "商品情報の取得に失敗しました"
        }
    }

    /// 購入。成功時は即座に isPurchased を更新。
    func purchase() async {
        guard let product else {
            errorMessage = "商品が読み込まれていません"
            return
        }
        do {
            let result = try await product.purchase()
            switch result {
            case let .success(verification):
                if case let .verified(transaction) = verification {
                    await transaction.finish()
                    isPurchased = true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "購入に失敗しました"
        }
    }

    /// 購入の復元（別端末・再インストール時）
    func restore() async {
        do {
            try await AppStore.sync()
            await refreshPurchasedState()
        } catch {
            errorMessage = "購入の復元に失敗しました"
        }
    }

    /// currentEntitlements から購入状態を導出
    func refreshPurchasedState() async {
        var purchased = false
        for await result in Transaction.currentEntitlements {
            if case let .verified(transaction) = result,
               transaction.productID == Self.premiumProductID,
               transaction.revocationDate == nil
            {
                purchased = true
            }
        }
        isPurchased = purchased
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                if case let .verified(transaction) = result {
                    await transaction.finish()
                    await self.refreshPurchasedState()
                }
            }
        }
    }
}
