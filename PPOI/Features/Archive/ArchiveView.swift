import SwiftUI

struct ArchiveView: View {
    @Environment(StoreManager.self) private var storeManager

    @State private var quotes: [Quote] = []
    @State private var isLoading = true

    /// 無料ユーザーに見せる日数
    private let freeLimit = 3

    private let service = ArchiveService()

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if quotes.isEmpty {
                ContentUnavailableView(
                    "過去の格言がありません",
                    systemImage: "book.closed",
                    description: Text("毎日アプリを開くと、ここに溜まっていきます。")
                )
            } else {
                List {
                    ForEach(Array(visibleQuotes.enumerated()), id: \.element.id) { index, quote in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(quote.displayDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(quote.text)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }

                    if !storeManager.isPurchased, quotes.count > freeLimit {
                        Section {
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
                                .padding(.vertical, 12)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("過去の格言")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            quotes = await service.fetchRecentQuotes()
            isLoading = false
        }
    }

    private var visibleQuotes: [Quote] {
        if storeManager.isPurchased {
            return quotes
        }
        return Array(quotes.prefix(freeLimit))
    }
}
