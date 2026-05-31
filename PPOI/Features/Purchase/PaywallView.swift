import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(StoreManager.self) private var store
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private var colors: ThemeColors { appState.store.selectedTheme.colors }

    private let benefits: [(icon: String, title: String, detail: String)] = [
        ("rectangle.slash", "広告を除去", "バナー・共有後の全画面広告が消えます"),
        ("paintpalette", "全テーマ解放", "和風・ポップ・ダークをいつでも"),
        ("heart.fill", "お気に入り強化", "保存した一句をいつでも振り返り"),
        ("hand.thumbsup", "個人開発を応援", "アップデートの励みになります")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    VStack(spacing: 16) {
                        ForEach(benefits, id: \.title) { benefit in
                            benefitRow(benefit)
                        }
                    }
                    .padding(.horizontal, 24)

                    purchaseSection
                        .padding(.horizontal, 24)

                    if let message = store.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Text("買い切り。サブスクリプションではありません。")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 32)
            }
            .navigationTitle("プレミアム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
            .task {
                if store.product == nil {
                    await store.loadProducts()
                }
            }
            .onChange(of: store.isPurchased) { _, purchased in
                if purchased { dismiss() }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundStyle(colors.accent)
            Text("っぽい格言 プレミアム")
                .font(.title2.weight(.bold))
            Text("広告なしで、もっと静かに一句と向き合う。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }

    private func benefitRow(_ benefit: (icon: String, title: String, detail: String)) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: benefit.icon)
                .font(.title3)
                .foregroundStyle(colors.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(benefit.title).font(.body.weight(.semibold))
                Text(benefit.detail).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var purchaseSection: some View {
        if store.isPurchased {
            Label("購入済み — ありがとうございます", systemImage: "checkmark.seal.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity)
                .padding()
        } else {
            VStack(spacing: 12) {
                Button {
                    Task { await store.purchase() }
                } label: {
                    Group {
                        if store.isLoading {
                            ProgressView()
                        } else {
                            Text(purchaseButtonTitle)
                                .font(.body.weight(.semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colors.button)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(store.product == nil || store.isLoading)

                Button("購入を復元") {
                    Task { await store.restore() }
                }
                .font(.footnote)
                .foregroundStyle(colors.accent)
            }
        }
    }

    private var purchaseButtonTitle: String {
        if let price = store.product?.displayPrice {
            return "\(price) で購入"
        }
        return "購入する"
    }
}

#Preview {
    PaywallView()
        .environment(StoreManager.shared)
        .environment(AppState())
}
