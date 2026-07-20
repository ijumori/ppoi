import SwiftUI

struct DailyQuestionView: View {
    let question: String
    let colors: ThemeColors

    var body: some View {
        ExpandableCard(
            icon: "questionmark.bubble",
            title: "今日の問い",
            colors: colors,
            expandedAccessibilityLabel: "今日の問いを閉じる",
            collapsedAccessibilityLabel: "今日の問いを見る"
        ) {
            Text(question)
                .font(.subheadline)
                .foregroundStyle(colors.primaryText.opacity(0.9))
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("今日の問い: \(question)")
        }
    }
}

#Preview {
    DailyQuestionView(
        question: "この格言を自分の仕事に当てはめると、何が思い浮かびますか？",
        colors: AppTheme.darkPremium.colors
    )
    .padding()
    .background(Color.black)
}
