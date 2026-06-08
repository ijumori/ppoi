import SwiftUI

struct QuoteView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = QuoteViewModel()
    @State private var streakRewardAlert: StreakReward?
    @State private var showShareReward = false

    private var theme: AppTheme { appState.store.selectedTheme }
    private var colors: ThemeColors { theme.colors }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                VStack(spacing: 32) {
                    Spacer()

                    if let quote = viewModel.quote {
                        VStack(spacing: 16) {
                            Text(quote.displayDate)
                                .font(.caption)
                                .foregroundStyle(colors.accent)

                            if appState.store.currentStreak >= 2 {
                                HStack(spacing: 8) {
                                    Label("\(appState.store.currentStreak)日連続", systemImage: "flame.fill")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(colors.accent)
                                    if appState.store.hasEarnedMasterTitle {
                                        Text("格言マスター")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(colors.accent)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(colors.accent.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                            }

                            Text("今日の「っぽい格言」")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(colors.accent.opacity(0.9))

                            Text(quote.text)
                                .font(quoteFont)
                                .foregroundStyle(colors.primaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .opacity(viewModel.appeared ? 1 : 0)
                                .animation(.easeIn(duration: 0.6), value: viewModel.appeared)

                            Text("AIが紡ぐ創作格言")
                                .font(.caption2)
                                .foregroundStyle(colors.accent.opacity(0.6))

                            VoteView(date: quote.date, accentColor: colors.accent)
                                .padding(.top, 8)
                        }
                    } else if viewModel.isLoading {
                        ProgressView()
                            .tint(colors.accent)
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Button(action: performQuickShare) {
                            HStack(spacing: 6) {
                                Text("𝕏")
                                    .font(.body.weight(.black))
                                Text("シェアする")
                                    .font(.body)
                            }
                        }
                        .foregroundStyle(theme == .minimal ? .white : colors.background)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colors.button)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button("考察を添えてシェア") {
                            viewModel.showShareSheet = true
                        }
                        .font(.caption)
                        .foregroundStyle(colors.accent.opacity(0.7))
                    }
                    .padding(.horizontal, 24)

                    BannerAdView()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                }

                if showShareReward {
                    ShareRewardView(
                        shareCount: appState.store.totalShareCount
                    ) {
                        withAnimation { showShareReward = false }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showShareReward)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let quote = viewModel.quote {
                        Button {
                            appState.store.toggleFavorite(quote)
                        } label: {
                            Image(systemName: appState.store.isFavorite(quote) ? "heart.fill" : "heart")
                                .foregroundStyle(colors.accent)
                        }
                        .accessibilityLabel(appState.store.isFavorite(quote) ? "お気に入り解除" : "お気に入りに追加")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            InviteManager.invite(quote: viewModel.quote)
                        } label: {
                            Image(systemName: "person.badge.plus")
                                .foregroundStyle(colors.accent)
                        }
                        Button {
                            viewModel.showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(colors.accent)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let quote = viewModel.quote {
                    ShareInputView(
                        quote: quote,
                        theme: theme,
                        fontVariant: appState.store.fontVariant,
                        onShareCompleted: {
                            appState.store.recordShare()
                            InterstitialAdManager.shared.showAfterShare()
                            showShareReward = true
                        }
                    )
                }
            }
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsView()
            }
        }
        .task {
            await viewModel.loadQuote(store: appState.store)
            viewModel.appeared = true

            streakRewardAlert = appState.store.checkAndUnlockStreakRewards()

            try? await Task.sleep(for: .seconds(2))
            ReviewPromptManager.requestIfEligible(store: appState.store)
        }
        .alert(
            streakRewardAlert == .masterTitle ? "格言マスター獲得！" : "新テーマ解放！",
            isPresented: Binding(
                get: { streakRewardAlert != nil },
                set: { if !$0 { streakRewardAlert = nil } }
            )
        ) {
            Button("OK") { streakRewardAlert = nil }
        } message: {
            switch streakRewardAlert {
            case .streakTheme:
                Text("7日連続閲覧達成！「禅・ゴールド」テーマが使えるようになりました。設定から変更できます。")
            case .masterTitle:
                Text("30日連続閲覧達成！「格言マスター」の称号を獲得しました。")
            case nil:
                Text("")
            }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if let gradient = colors.gradient {
            gradient.ignoresSafeArea()
        } else {
            colors.background.ignoresSafeArea()
        }
    }

    private var quoteFont: Font {
        let design: Font.Design = appState.store.fontVariant == .serif ? .serif : .default
        return .system(size: 32, weight: .medium, design: design)
    }

    /// 1タップシェア：考察なしで即座にシェアシートを表示
    private func performQuickShare() {
        guard let quote = viewModel.quote else { return }
        let text = ShareTextBuilder.build(reflection: "")
        var items: [Any] = [text]

        if let image = ShareImageRenderer.render(
            quote: quote,
            reflection: "",
            theme: theme,
            fontVariant: appState.store.fontVariant
        ) {
            items.append(image)
        }

        ShareActivityPresenter.present(items: items) { completed in
            if completed {
                appState.store.recordShare()
                InterstitialAdManager.shared.showAfterShare()
                showShareReward = true
            }
        }
    }

}

#Preview {
    QuoteView()
        .environment(AppState())
        .environment(StoreManager.shared)
}
