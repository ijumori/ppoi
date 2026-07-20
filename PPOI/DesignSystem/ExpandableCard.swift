import SwiftUI

/// アイコン + 見出しのヘッダーをタップして本文を開閉する共通カード。
/// `InterpretationView` と `DailyQuestionView` の重複していた開閉 UI を統合する。
///
/// 本文の幅制御（`.frame` など）は呼び出し側の `content` に委ねる。
/// 開閉トグルの状態はこのカードが保持する。
struct ExpandableCard<Content: View>: View {
    let icon: String
    let title: String
    let colors: ThemeColors
    /// 展開時に読み上げるラベル。未指定なら `title`。
    var expandedAccessibilityLabel: String?
    /// 折りたたみ時に読み上げるラベル。未指定なら `title`。
    var collapsedAccessibilityLabel: String?
    @ViewBuilder let content: () -> Content

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(colors.accent)
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(colors.accent)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(colors.accent.opacity(0.7))
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)
                .background(colors.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Radius.l))
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
            .accessibilityLabel(
                isExpanded
                    ? (expandedAccessibilityLabel ?? title)
                    : (collapsedAccessibilityLabel ?? title)
            )

            if isExpanded {
                content()
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.m)
                    .background(colors.accent.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.l))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
