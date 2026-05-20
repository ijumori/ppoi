import SwiftUI

struct QuoteView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = QuoteViewModel()

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
                            Text(displayDate)
                                .font(.caption)
                                .foregroundStyle(colors.accent)

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
                        }
                    } else if viewModel.isLoading {
                        ProgressView()
                            .tint(colors.accent)
                    }

                    Spacer()

                    Button("考察してシェアする") {
                        viewModel.showShareSheet = true
                    }
                    .font(.body)
                    .foregroundStyle(theme == .minimal ? .white : colors.background)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colors.button)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)

                    BannerAdView()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(colors.accent)
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
                            InterstitialAdManager.shared.showAfterShare()
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

    private var displayDate: String {
        DateFormatter.jstDisplay.string(from: Date())
    }
}

#Preview {
    QuoteView()
        .environment(AppState())
}
