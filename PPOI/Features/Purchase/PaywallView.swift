import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(StoreManager.self) private var store
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var showCelebration = false

    private var colors: ThemeColors {
        appState.store.selectedTheme.colors
    }

    private let benefits: [(icon: String, title: String, detail: String)] = [
        ("rectangle.slash", "広告を完全除去", "バナー・シェア後の全画面広告が消えます"),
        ("paintpalette", "全テーマ解放", "プレミアム限定テーマを含む全テーマが使えます"),
        ("books.vertical", "全アーカイブ解放", "過去の全格言をいつでも振り返れます"),
        ("heart.fill", "お気に入り無制限", "保存上限なしで一句をいつでも振り返り"),
        ("lightbulb", "AI解読が無制限", "格言の深い解釈をいつでも確認できます"),
        ("hand.thumbsup", "個人開発を応援", "アップデートの励みになります"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
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
                            .accessibilityLabel("閉じる")
                    }
                }
                .task {
                    if store.product == nil {
                        await store.loadProducts()
                    }
                }
                .onChange(of: store.isPurchased) { _, purchased in
                    if purchased {
                        showCelebration = true
                    }
                }

                if showCelebration {
                    PurchaseCelebrationView {
                        showCelebration = false
                        dismiss()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.4), value: showCelebration)
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
        .accessibilityElement(children: .combine)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(benefit.title)。\(benefit.detail)")
    }

    @ViewBuilder
    private var purchaseSection: some View {
        if store.isPurchased {
            Label("購入済み — ありがとうございます", systemImage: "checkmark.seal.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity)
                .padding()
                .accessibilityLabel("プレミアム購入済み")
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
                .accessibilityLabel(purchaseButtonTitle)

                Button("購入を復元") {
                    Task { await store.restore() }
                }
                .font(.footnote)
                .foregroundStyle(colors.accent)
                .accessibilityLabel("過去の購入を復元")
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

// MARK: - Purchase Celebration

struct PurchaseCelebrationView: View {
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var confettiPhase = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.yellow)
                    .scaleEffect(appeared ? 1.0 : 0.3)
                    .opacity(appeared ? 1 : 0)

                Text("プレミアムへようこそ！")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Text("広告なしの静かな体験をお楽しみください")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .opacity(appeared ? 1 : 0)

                Button {
                    onDismiss()
                } label: {
                    Text("はじめる")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                        .background(.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .opacity(appeared ? 1 : 0)
                .padding(.top, 8)
            }
        }
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("プレミアム購入完了！おめでとうございます")
    }
}

#Preview {
    PaywallView()
        .environment(StoreManager.shared)
        .environment(AppState())
}
