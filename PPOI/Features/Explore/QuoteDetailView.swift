import SwiftUI

struct QuoteDetailView: View {
    let quote: Quote
    @Environment(AppState.self) private var appState

    private var colors: ThemeColors {
        appState.store.selectedTheme.colors
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                Text(quote.displayDate)
                    .font(.caption)
                    .foregroundStyle(colors.accent)

                Text(quote.text)
                    .font(.system(size: 28, weight: .medium, design: appState.store.fontVariant == .serif ? .serif : .default))
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("AIが紡ぐ創作格言")
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
            if let gradient = colors.gradient {
                gradient.ignoresSafeArea()
            } else {
                colors.background.ignoresSafeArea()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.store.toggleFavorite(quote)
                } label: {
                    Image(systemName: appState.store.isFavorite(quote) ? "heart.fill" : "heart")
                        .foregroundStyle(colors.accent)
                }
                .accessibilityLabel(appState.store.isFavorite(quote) ? "お気に入り解除" : "お気に入りに追加")
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuoteDetailView(quote: .placeholder)
            .environment(AppState())
    }
}
