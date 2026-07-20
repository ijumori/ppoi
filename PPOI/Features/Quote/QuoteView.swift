import SwiftUI

struct QuoteView: View {
    @Environment(AppState.self) private var appState
    @Environment(JournalStore.self) private var journalStore
    @Environment(StoreManager.self) private var storeManager
    @State private var viewModel = QuoteViewModel()
    @State private var streakRewardAlert: StreakReward?
    @State private var showShareReward = false
    @State private var favoriteScale: CGFloat = 1.0
    @State private var showFavoritesPaywall = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var theme: AppTheme {
        appState.preferences.selectedTheme
    }

    private var colors: ThemeColors {
        theme.colors
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                VStack(spacing: 24) {
                    Spacer()

                    if let quote = viewModel.quote {
                        VStack(spacing: 16) {
                            Text(quote.displayDate)
                                .font(.caption)
                                .foregroundStyle(colors.accent)
                                .accessibilityLabel("\(quote.displayDate)の格言")

                            if appState.streak.currentStreak >= 2 {
                                HStack(spacing: 8) {
                                    Label("\(appState.streak.currentStreak)日連続", systemImage: "flame.fill")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(colors.accent)
                                    if appState.rewards.hasEarnedMasterTitle {
                                        Text("格言マスター")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(colors.accent)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(colors.accent.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                                .accessibilityLabel("\(appState.streak.currentStreak)日連続閲覧\(appState.rewards.hasEarnedMasterTitle ? "、格言マスター" : "")")
                            }

                            Text("今日の「っぽい格言」")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(colors.accent.opacity(0.9))

                            Text(quote.text)
                                .font(quoteFont)
                                .foregroundStyle(colors.primaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .blur(radius: viewModel.appeared ? 0 : 8)
                                .opacity(viewModel.appeared ? 1 : 0)
                                .animation(
                                    reduceMotion ? .none : .easeOut(duration: 0.8),
                                    value: viewModel.appeared
                                )
                                .accessibilityLabel(quote.text)

                            Text(AppStrings.creativeQuoteCredit)
                                .font(.caption2)
                                .foregroundStyle(colors.accent.opacity(0.6))

                            VoteView(date: quote.date, accentColor: colors.accent)
                                .padding(.top, 8)

                            if let interpretation = quote.interpretation {
                                InterpretationView(text: interpretation, colors: colors)
                                    .padding(.horizontal, 24)
                            }

                            if let question = quote.question {
                                DailyQuestionView(question: question, colors: colors)
                                    .padding(.horizontal, 24)
                            }

                            JournalEntryView(date: quote.date, colors: colors)
                                .padding(.horizontal, 24)
                        }
                    } else if viewModel.isLoading {
                        ProgressView()
                            .tint(colors.accent)
                            .accessibilityLabel("格言を読み込み中")
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Button(action: performXShare) {
                            HStack(spacing: 6) {
                                Text("𝕏")
                                    .font(.body.weight(.black))
                                Text("シェアする")
                                    .font(.body)
                            }
                        }
                        .sensoryFeedback(.impact(flexibility: .soft), trigger: showShareReward)
                        .foregroundStyle(theme == .minimal ? .white : colors.background)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colors.button)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Xでシェアする")

                        Button("考察を添えてシェア") {
                            viewModel.showShareSheet = true
                        }
                        .font(.caption)
                        .foregroundStyle(colors.accent.opacity(0.7))
                        .accessibilityLabel("考察を添えてシェアする")
                    }
                    .padding(.horizontal, 24)

                    BannerAdView()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                }

                if showShareReward {
                    ShareRewardView(
                        shareCount: appState.preferences.totalShareCount
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
                            let result = appState.favorites.toggleFavorite(quote, isPremium: storeManager.isPurchased)
                            if case let .limitReached(_, isPremium) = result, !isPremium {
                                showFavoritesPaywall = true
                                return
                            }
                            if !reduceMotion {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    favoriteScale = 1.3
                                }
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) {
                                    favoriteScale = 1.0
                                }
                            }
                        } label: {
                            Image(systemName: appState.favorites.isFavorite(quote) ? "heart.fill" : "heart")
                                .foregroundStyle(colors.accent)
                                .scaleEffect(favoriteScale)
                        }
                        .sensoryFeedback(.impact(flexibility: .soft), trigger: appState.favorites.isFavorite(quote))
                        .accessibilityLabel(appState.favorites.isFavorite(quote) ? "お気に入り解除" : "お気に入りに追加")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        InviteManager.invite(quote: viewModel.quote)
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .foregroundStyle(colors.accent)
                    }
                    .accessibilityLabel("友達に教える")
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let quote = viewModel.quote {
                    ShareInputView(
                        quote: quote,
                        theme: theme,
                        fontVariant: appState.preferences.fontVariant,
                        onShareCompleted: {
                            appState.preferences.recordShare()
                            InterstitialAdManager.shared.showAfterShare()
                            showShareReward = true
                        }
                    )
                }
            }
            .sheet(isPresented: $showFavoritesPaywall) {
                PaywallView()
                    .environment(StoreManager.shared)
                    .environment(appState)
            }
        }
        .task {
            await viewModel.loadQuote()
            appState.streak.registerTodayVisit()
            viewModel.appeared = true

            streakRewardAlert = appState.rewards.checkAndUnlockRewards(streak: appState.streak.currentStreak)

            try? await Task.sleep(for: .seconds(2))
            ReviewPromptManager.requestIfEligible(preferences: appState.preferences, streak: appState.streak)
        }
        .alert(
            streakRewardAlert == .masterTitle ? "格言マスター獲得！" : "新テーマ解放！",
            isPresented: Binding(
                get: { streakRewardAlert != nil },
                set: {
                    if !$0 {
                        streakRewardAlert = nil
                    }
                }
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
        let design: Font.Design = appState.preferences.fontVariant == .serif ? .serif : .default
        return .system(size: 32, weight: .medium, design: design)
    }

    /// X直接シェア：twitter:// → web intent → UIActivityViewController
    private func performXShare() {
        guard let quote = viewModel.quote else { return }
        let text = XShareService.buildShareText(quote: quote)
        let image = ShareImageRenderer.render(
            quote: quote,
            reflection: "",
            theme: theme,
            fontVariant: appState.preferences.fontVariant
        )
        XShareService.shareToX(text: text, image: image)
        appState.preferences.recordShare()
        InterstitialAdManager.shared.showAfterShare()
        showShareReward = true
    }
}

#Preview {
    QuoteView()
        .environment(AppState())
        .environment(StoreManager.shared)
}
