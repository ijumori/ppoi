import SwiftUI

struct DailyQuestionView: View {
    let question: String
    let colors: ThemeColors

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "questionmark.bubble")
                        .foregroundStyle(colors.accent)
                    Text("今日の問い")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(colors.accent)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(colors.accent.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(colors.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
            .accessibilityLabel(isExpanded ? "今日の問いを閉じる" : "今日の問いを見る")

            if isExpanded {
                Text(question)
                    .font(.subheadline)
                    .foregroundStyle(colors.primaryText.opacity(0.9))
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(colors.accent.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .accessibilityLabel("今日の問い: \(question)")
            }
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
