import SwiftUI

struct InterpretationView: View {
    let text: String
    let colors: ThemeColors

    @State private var isExpanded = false
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundStyle(colors.accent)
                    Text("この格言を解読する")
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
            .accessibilityLabel(isExpanded ? "解読を閉じる" : "この格言を解読する")

            if isExpanded {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(colors.primaryText.opacity(0.85))
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(colors.accent.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -8)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.3)) {
                            appeared = true
                        }
                    }
                    .onDisappear {
                        appeared = false
                    }
                    .accessibilityLabel("AI解読: \(text)")
            }
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
