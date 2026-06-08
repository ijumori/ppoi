import SwiftUI

struct RootView: View {
    @Bindable var appState: AppState

    @State private var isEnvironmentTrusted = true
    @State private var isCaptured = false
    @State private var isInBackground = false

    var body: some View {
        Group {
            if !isEnvironmentTrusted {
                SecurityBlockedView()
            } else {
                ZStack {
                    contentView

                    // B5: Screen capture warning overlay
                    if isCaptured {
                        screenCaptureOverlay
                    }

                    // B4: Background snapshot protection
                    if isInBackground {
                        snapshotProtection
                    }
                }
            }
        }
        .environment(appState)
        .environment(StoreManager.shared)
        .preferredColorScheme(appState.store.selectedTheme == .darkPremium ? .dark : nil)
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
        .onAppear {
            performSecurityCheck()
            updateCapturedState()
            StoreManager.shared.start()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
        ) { _ in
            isInBackground = true
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
        ) { _ in
            isInBackground = false
            performSecurityCheck()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)
        ) { _ in
            updateCapturedState()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if appState.hasCompletedOnboarding {
            QuoteView()
        } else {
            OnboardingView()
        }
    }

    // MARK: - B5: Screen Capture Warning

    private var screenCaptureOverlay: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text("画面録画を検知しました")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("画面の内容は保護されています。")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    // MARK: - B4: Background Snapshot Protection

    private var snapshotProtection: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.gray)

                Text("っぽい格言")
                    .font(.headline)
                    .foregroundStyle(.gray)
            }
        }
    }

    // MARK: - Security Checks

    private func performSecurityCheck() {
        #if !targetEnvironment(simulator)
        isEnvironmentTrusted = SecurityGuard.isEnvironmentTrusted
        #endif
    }

    private func updateCapturedState() {
        isCaptured = UIScreen.main.isCaptured
    }
}

#Preview {
    RootView(appState: AppState())
}
