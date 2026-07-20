import SwiftUI

struct InterpretationView: View {
    let text: String
    let colors: ThemeColors

    var body: some View {
        ExpandableCard(
            icon: "lightbulb",
            title: "この格言を解読する",
            colors: colors,
            expandedAccessibilityLabel: "解読を閉じる",
            collapsedAccessibilityLabel: "この格言を解読する"
        ) {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(colors.primaryText.opacity(0.85))
                .lineSpacing(4)
                .accessibilityLabel("AI解読: \(text)")
        }
    }
}

#Preview {
    InterpretationView(
        text: "この格言は、人生における偶然の出会いの大切さを説いています。計画通りにいかないことにこそ、真の成長の種が潜んでいるのかもしれません。",
        colors: AppTheme.darkPremium.colors
    )
    .padding()
    .background(Color.black)
}
