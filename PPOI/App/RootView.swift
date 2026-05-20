import SwiftUI

struct RootView: View {
    @Bindable var appState: AppState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                QuoteView()
            } else {
                OnboardingView()
            }
        }
        .environment(appState)
        .preferredColorScheme(appState.store.selectedTheme == .darkPremium ? .dark : nil)
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
    }
}

#Preview {
    RootView(appState: AppState())
}
