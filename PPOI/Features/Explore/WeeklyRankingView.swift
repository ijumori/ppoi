import SwiftUI

struct WeeklyRankingView: View {
    @Environment(AppState.self) private var appState
    let ranking: [RankedQuote]

    private var colors: ThemeColors {
        appState.preferences.selectedTheme.colors
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                Text("今週のベスト")
                    .font(.headline)
                    .foregroundStyle(colors.primaryText)
            }
            .padding(.horizontal)

            ForEach(Array(ranking.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: 12) {
                    Text(rankMedal(index))
                        .font(.title3)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.quote.text)
                            .font(.subheadline)
                            .foregroundStyle(colors.primaryText)
                            .lineLimit(2)
                        Text(item.quote.displayDate)
                            .font(.caption2)
                            .foregroundStyle(colors.accent.opacity(0.6))
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text(item.topReaction)
                            .font(.title3)
                        Text("\(item.totalVotes)")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(index + 1)位、\(item.quote.text)、合計\(item.totalVotes)票")
            }
        }
        .padding(.vertical, 12)
        .background(colors.accent.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func rankMedal(_ index: Int) -> String {
        switch index {
        case 0: "🥇"
        case 1: "🥈"
        default: "🥉"
        }
    }
}
