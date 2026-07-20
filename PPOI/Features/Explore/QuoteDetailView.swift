import SwiftUI

struct QuoteDetailView: View {
    let quote: Quote
    @Environment(AppState.self) private var appState
    @Environment(StoreManager.self) private var storeManager
    @State private var showFavoritesPaywall = false

    private var colors: ThemeColors {
        appState.preferences.selectedTheme.colors
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                Text(quote.displayDate)
                    .font(.caption)
                    .foregroundStyle(colors.accent)

                Text(quote.text)
                    .font(.system(size: 28, weight: .medium, design: appState.preferences.fontVariant == .serif ? Font.Design.serif : .default))
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text(AppStrings.creativeQuoteCredit)
                    .font(.caption2)
                    .foregroundStyle(colors.accent.opacity(0.6))

                if let interpretation = quote.interpretation {
                    InterpretationView(text: interpretation, colors: colors)
                        .padding(.horizontal, 24)
                }

                Spacer(minLength: 40)
            }
        }
        .background {
            ThemedBackground(colors: colors)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let result = appState.favorites.toggleFavorite(quote, isPremium: storeManager.isPurchased)
                    if case let .limitReached(_, isPremium) = result, !isPremium {
                        showFavoritesPaywall = true
                    }
                } label: {
                    Image(systemName: appState.favorites.isFavorite(quote) ? "heart.fill" : "heart")
                        .foregroundStyle(colors.accent)
                }
                .accessibilityLabel(appState.favorites.isFavorite(quote) ? "お気に入り解除" : "お気に入りに追加")
            }
        }
        .sheet(isPresented: $showFavoritesPaywall) {
            PaywallView()
                .environment(StoreManager.shared)
                .environment(appState)
        }
    }
}

#Preview {
    NavigationStack {
        QuoteDetailView(quote: .placeholder)
            .environment(AppState())
            .environment(StoreManager.shared)
    }
}
