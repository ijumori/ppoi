import SwiftUI

// オンボーディングの各ページ。表示専用で、テーマ色と出現アニメの状態のみ受け取る。

/// Page 1: AI格言コンセプト
struct OnboardingPage1: View {
    let colors: ThemeColors
    let appeared: Bool

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "text.quote")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.5)

            Text("今日だけ、届く一句")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Text("毎日1つ、AIが紡ぐ「っぽい格言」が届きます。\n明日にはもう見られません。")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
                .opacity(appeared ? 1 : 0)

            Text("※ AIが作る、それっぽい創作です。実在の名言ではありません。")
                .font(.footnote)
                .foregroundStyle(colors.primaryText.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("今日だけ届く一句。毎日1つAIが紡ぐっぽい格言が届きます。")
    }
}

/// Page 2: シェアカード
struct OnboardingPage2: View {
    let colors: ThemeColors
    let appeared: Bool

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "square.and.arrow.up.on.square")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.5)

            Text("解釈よ、渦となれ")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Text("あなたの考察を添えて𝕏にシェア。\n美しいカード画像が自動で生成されます。")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
                .opacity(appeared ? 1 : 0)

            // Mock share card
            RoundedRectangle(cornerRadius: Radius.xl)
                .fill(colors.accent.opacity(0.1))
                .frame(height: 120)
                .overlay {
                    VStack(spacing: Spacing.s) {
                        Text("「静寂の中にこそ、真の答えは眠っている」")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(colors.primaryText)
                        Text(AppStrings.hashtag)
                            .font(.caption2)
                            .foregroundStyle(colors.accent)
                    }
                    .padding()
                }
                .padding(.horizontal, 40)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.9)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("解釈よ渦となれ。考察を添えてXにシェアできます。")
    }
}

/// Page 3: テーマ選択
struct OnboardingPage3: View {
    let colors: ThemeColors
    let appeared: Bool

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "paintpalette")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.5)

            Text("あなた好みの空間で")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Text("和風ミニマル、モダン・ポップ、ダーク・プレミア。\n気分に合わせてテーマを切り替えられます。")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
                .opacity(appeared ? 1 : 0)

            HStack(spacing: Spacing.m) {
                ForEach([AppTheme.minimal, .pop, .darkPremium], id: \.self) { t in
                    RoundedRectangle(cornerRadius: Radius.m)
                        .fill(t.colors.background)
                        .frame(width: 64, height: 64)
                        .overlay {
                            RoundedRectangle(cornerRadius: Radius.m)
                                .stroke(t.colors.accent, lineWidth: 2)
                        }
                        .overlay {
                            Text("あ")
                                .font(.system(.title3, design: .serif))
                                .foregroundStyle(t.colors.primaryText)
                        }
                }
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.9)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("テーマを選べます。和風ミニマル、モダンポップ、ダークプレミアの3種類。")
    }
}

/// Page 4: 通知許可
struct OnboardingPage4: View {
    let colors: ThemeColors
    let appeared: Bool

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Image(systemName: "bell.badge")
                .font(.system(size: 56))
                .foregroundStyle(colors.accent)
                .symbolEffect(.bounce, value: appeared)
                .opacity(appeared ? 1 : 0)

            Text("毎日の一句を逃さない")
                .font(.system(.title, design: .serif, weight: .bold))
                .foregroundStyle(colors.accent)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Text("通知をオンにすると、\n毎日決まった時間に新しい格言をお届けします。\n連続閲覧で特別テーマも解放！")
                .font(.body)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
                .opacity(appeared ? 1 : 0)

            HStack(spacing: Spacing.l) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(StreakReward.streakThemeDays)日連続 → 禅・ゴールドテーマ")
                    .font(.caption)
                    .foregroundStyle(colors.primaryText.opacity(0.7))
            }
            .opacity(appeared ? 1 : 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("通知をオンにすると毎日格言が届きます。\(StreakReward.streakThemeDays)日連続閲覧で特別テーマが解放されます。")
    }
}
