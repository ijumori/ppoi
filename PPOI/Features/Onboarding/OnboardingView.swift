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
                    case 0: page1
                    case 1: page2
                    case 2: page3
                    default: page4
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

    // MARK: - Page 1: AI格言コンセプト

    private var page1: some View {
        VStack(spacing: 24) {
            Image(systemName: "text.quote")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent)
                .opacity(elementAppeared ? 1 : 0)
                .scaleEffect(elementAppeared ? 1 : 0.5)

            Text("今日だけ、届く一句")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)
                .opacity(elementAppeared ? 1 : 0)
                .offset(y: elementAppeared ? 0 : 20)

            Text("毎日1つ、AIが紡ぐ「っぽい格言」が届きます。\n明日にはもう見られません。")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(elementAppeared ? 1 : 0)

            Text("※ AIが作る、それっぽい創作です。実在の名言ではありません。")
                .font(.footnote)
                .foregroundStyle(colors.primaryText.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("今日だけ届く一句。毎日1つAIが紡ぐっぽい格言が届きます。")
    }

    // MARK: - Page 2: シェアカード

    private var page2: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.and.arrow.up.on.square")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent)
                .opacity(elementAppeared ? 1 : 0)
                .scaleEffect(elementAppeared ? 1 : 0.5)

            Text("解釈よ、渦となれ")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)
                .opacity(elementAppeared ? 1 : 0)
                .offset(y: elementAppeared ? 0 : 20)

            Text("あなたの考察を添えて𝕏にシェア。\n美しいカード画像が自動で生成されます。")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(elementAppeared ? 1 : 0)

            // Mock share card
            RoundedRectangle(cornerRadius: 12)
                .fill(colors.accent.opacity(0.1))
                .frame(height: 120)
                .overlay {
                    VStack(spacing: 8) {
                        Text("「静寂の中にこそ、真の答えは眠っている」")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(colors.primaryText)
                        Text("#っぽい格言")
                            .font(.caption2)
                            .foregroundStyle(colors.accent)
                    }
                    .padding()
                }
                .padding(.horizontal, 40)
                .opacity(elementAppeared ? 1 : 0)
                .scaleEffect(elementAppeared ? 1 : 0.9)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("解釈よ渦となれ。考察を添えてXにシェアできます。")
    }

    // MARK: - Page 3: テーマ選択

    private var page3: some View {
        VStack(spacing: 24) {
            Image(systemName: "paintpalette")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent)
                .opacity(elementAppeared ? 1 : 0)
                .scaleEffect(elementAppeared ? 1 : 0.5)

            Text("あなた好みの空間で")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)
                .opacity(elementAppeared ? 1 : 0)
                .offset(y: elementAppeared ? 0 : 20)

            Text("和風ミニマル、モダン・ポップ、ダーク・プレミア。\n気分に合わせてテーマを切り替えられます。")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(elementAppeared ? 1 : 0)

            HStack(spacing: 12) {
                ForEach([AppTheme.minimal, .pop, .darkPremium], id: \.self) { t in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(t.colors.background)
                        .frame(width: 64, height: 64)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(t.colors.accent, lineWidth: 2)
                        }
                        .overlay {
                            Text("あ")
                                .font(.system(.title3, design: .serif))
                                .foregroundStyle(t.colors.primaryText)
                        }
                }
            }
            .opacity(elementAppeared ? 1 : 0)
            .scaleEffect(elementAppeared ? 1 : 0.9)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("テーマを選べます。和風ミニマル、モダンポップ、ダークプレミアの3種類。")
    }

    // MARK: - Page 4: 通知許可

    private var page4: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent)
                .symbolEffect(.bounce, value: elementAppeared)
                .opacity(elementAppeared ? 1 : 0)

            Text("毎日の一句を逃さない")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)
                .opacity(elementAppeared ? 1 : 0)
                .offset(y: elementAppeared ? 0 : 20)

            Text("通知をオンにすると、\n毎日決まった時間に新しい格言をお届けします。\n連続閲覧で特別テーマも解放！")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(elementAppeared ? 1 : 0)

            HStack(spacing: 16) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("7日連続 → 禅・ゴールドテーマ")
                    .font(.caption)
                    .foregroundStyle(colors.primaryText.opacity(0.7))
            }
            .opacity(elementAppeared ? 1 : 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("通知をオンにすると毎日格言が届きます。7日連続閲覧で特別テーマが解放されます。")
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
