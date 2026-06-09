import SwiftUI

struct ExploreView: View {
    @Environment(AppState.self) private var appState
    @Environment(StoreManager.self) private var storeManager

    @State private var quotes: [Quote] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedCategory: QuoteCategory?

    private let service = ArchiveService()
    private let freeLimit = 3

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredQuotes.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            categoryPicker
                                .padding(.bottom, 8)

                            ForEach(visibleQuotes) { quote in
                                NavigationLink(value: quote) {
                                    quoteRow(quote)
                                }
                                .buttonStyle(.plain)

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
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "格言を検索")
            .navigationDestination(for: Quote.self) { quote in
                QuoteDetailView(quote: quote)
            }
            .task {
                quotes = await service.fetchRecentQuotes(limit: 100)
                isLoading = false
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(nil, label: "すべて")
                ForEach(QuoteCategory.allCases) { category in
                    categoryChip(category, label: category.label)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func categoryChip(_ category: QuoteCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        let colors = appState.store.selectedTheme.colors
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            Text(label)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
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
        let colors = appState.store.selectedTheme.colors
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(quote.displayDate)
                    .font(.caption)
                    .foregroundStyle(colors.accent.opacity(0.7))
                Spacer()
                if appState.store.isFavorite(quote) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(colors.accent)
                }
            }
            Text(quote.text)
                .font(.body)
                .foregroundStyle(colors.primaryText)
                .lineLimit(2)
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
            result = result.filter { $0.tone == category.tone }
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
}
