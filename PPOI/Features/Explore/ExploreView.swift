import SwiftUI

struct ExploreView: View {
    @Environment(AppState.self) private var appState
    @Environment(StoreManager.self) private var storeManager
    @Environment(AchievementStore.self) private var achievementStore

    @State private var quotes: [Quote] = []
    @State private var ranking: [RankedQuote] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedCategory: QuoteCategory?

    private let service = ArchiveService()
    private let rankingService = RankingService()
    private let freeLimit = 10

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // ランキングセクション（検索・フィルタ未適用時のみ表示）
                            if searchText.isEmpty, selectedCategory == nil, !ranking.isEmpty {
                                WeeklyRankingView(ranking: ranking)
                                    .padding(.vertical, 12)
                            }

                            categoryPicker
                                .padding(.bottom, 4)

                            if filteredQuotes.isEmpty {
                                ContentUnavailableView.search(text: searchText)
                                    .padding(.top, 40)
                            } else {
                                ForEach(visibleQuotes) { quote in
                                    NavigationLink(value: quote) {
                                        quoteRow(quote)
                                    }
                                    .buttonStyle(.plain)
                                    .simultaneousGesture(TapGesture().onEnded {
                                        achievementStore.incrementExploreView()
                                    })

                                    Divider()
                                        .padding(.horizontal)
                                }

                                if !storeManager.isPurchased, filteredQuotes.count > freeLimit {
                                    paywallBanner
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "格言を検索")
            .navigationDestination(for: Quote.self) { quote in
                QuoteDetailView(quote: quote)
            }
            .task {
                async let quotesTask = service.fetchRecentQuotes(limit: 100)
                async let rankingTask = rankingService.fetchWeeklyRanking()
                quotes = await quotesTask
                ranking = await rankingTask
                isLoading = false
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(nil, label: "すべて", icon: nil)
                ForEach(QuoteCategory.allCases) { category in
                    categoryChip(category, label: category.label, icon: category.icon)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func categoryChip(_ category: QuoteCategory?, label: String, icon: String?) -> some View {
        let isSelected = selectedCategory == category
        let colors = appState.preferences.selectedTheme.colors
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(label)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? colors.background : colors.primaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? colors.accent : colors.accent.opacity(0.12))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label)カテゴリ")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func quoteRow(_ quote: Quote) -> some View {
        let colors = appState.preferences.selectedTheme.colors
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                if let category = quote.category {
                    Label(category.label, systemImage: category.icon)
                        .font(.caption2)
                        .foregroundStyle(colors.accent.opacity(0.7))
                } else {
                    Text(quote.displayDate)
                        .font(.caption)
                        .foregroundStyle(colors.accent.opacity(0.7))
                }
                Spacer()
                if appState.favorites.isFavorite(quote) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(colors.accent)
                }
            }
            Text(quote.text)
                .font(.body)
                .foregroundStyle(colors.primaryText)
                .lineLimit(2)
            Text(quote.displayDate)
                .font(.caption2)
                .foregroundStyle(colors.accent.opacity(0.4))
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(quote.displayDate)の格言、\(quote.text)")
    }

    private var paywallBanner: some View {
        NavigationLink {
            PaywallView()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("過去の格言をもっと見る")
                    .font(.subheadline.weight(.semibold))
                Text("プレミアムで全期間の格言を閲覧できます")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .accessibilityLabel("プレミアムで全期間の格言を閲覧")
    }

    private var filteredQuotes: [Quote] {
        var result = quotes
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    private var visibleQuotes: [Quote] {
        if storeManager.isPurchased {
            return filteredQuotes
        }
        return Array(filteredQuotes.prefix(freeLimit))
    }
}

#Preview {
    ExploreView()
        .environment(AppState())
        .environment(StoreManager.shared)
        .environment(AchievementStore())
}
