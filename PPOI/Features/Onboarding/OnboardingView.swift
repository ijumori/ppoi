import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var page = 0
    @State private var elementAppeared = false

    private let notificationService = NotificationService()
    private let colors = AppTheme.darkPremium.colors
    private let totalPages = 4

    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Group {
                    switch page {
                    case 0: OnboardingPage1(colors: colors, appeared: elementAppeared)
                    case 1: OnboardingPage2(colors: colors, appeared: elementAppeared)
                    case 2: OnboardingPage3(colors: colors, appeared: elementAppeared)
                    default: OnboardingPage4(colors: colors, appeared: elementAppeared)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(page)

                Spacer()

                pageIndicator
                    .padding(.bottom, 16)

                buttonSection
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: page)
        .onChange(of: page) { _, _ in
            elementAppeared = false
            withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
                elementAppeared = true
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                elementAppeared = true
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< totalPages, id: \.self) { index in
                Circle()
                    .fill(index == page ? colors.accent : colors.accent.opacity(0.3))
                    .frame(width: index == page ? 10 : 6, height: index == page ? 10 : 6)
                    .animation(.easeInOut(duration: 0.2), value: page)
            }
        }
        .accessibilityLabel("ページ\(page + 1)/\(totalPages)")
    }

    // MARK: - Button Section

    @ViewBuilder
    private var buttonSection: some View {
        if page < totalPages - 1 {
            Button {
                withAnimation {
                    page += 1
                }
            } label: {
                Text("次へ")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(colors.background)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colors.button)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: page)
            .accessibilityLabel("次のページへ")
        } else {
            VStack(spacing: 12) {
                Button {
                    finishOnboarding(requestNotification: true)
                } label: {
                    Text("通知を許可してはじめる")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(colors.background)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(colors.button)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.success, trigger: page)
                .accessibilityLabel("通知を許可してアプリを始める")

                Button {
                    finishOnboarding(requestNotification: false)
                } label: {
                    Text("通知なしではじめる")
                        .font(.body)
                        .foregroundStyle(colors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("通知なしでアプリを始める")
            }
        }
    }

    // MARK: - Actions

    private func finishOnboarding(requestNotification: Bool) {
        appState.finishOnboarding(requestNotification: requestNotification)

        guard requestNotification else { return }

        Task { @MainActor in
            let granted = await notificationService.requestAuthorization()
            appState.updateNotificationPermission(granted: granted)
            await notificationService.scheduleDailyNotification(
                hour: appState.preferences.notificationHour,
                enabled: granted
            )
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
