import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var page = 0

    private let notificationService = NotificationService()
    private let colors = AppTheme.darkPremium.colors

    var body: some View {
        ZStack {
            colors.background.ignoresSafeArea()

            page1
                .opacity(page == 0 ? 1 : 0)
                .allowsHitTesting(page == 0)

            page2
                .opacity(page == 1 ? 1 : 0)
                .allowsHitTesting(page == 1)
        }
        .animation(.easeInOut(duration: 0.25), value: page)
    }

    // MARK: - Page 1

    private var page1: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("今日だけ、届く一句")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)

            Text("毎日1つ、「っぽい格言」が届きます。\n明日にはもう見られません。")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("※ AIが作る、それっぽい創作です。実在の名言ではありません。")
                .font(.footnote)
                .foregroundStyle(colors.primaryText.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                withAnimation {
                    page = 1
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
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Page 2

    private var page2: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("解釈よ、渦となれ")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)

            Text("この一句に、正解は宿らない。あなたがどう読んだか——それだけが、残る。𝕏に解釈を放てば、やがて笑いの連鎖となり、やがて誰かの名言となる。一句から、渦は生まれる。")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

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
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
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
                hour: appState.store.notificationHour,
                enabled: granted
            )
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
