import SwiftUI

struct JournalHistoryView: View {
    @Environment(AppState.self) private var appState
    @Environment(JournalStore.self) private var journalStore

    private var colors: ThemeColors {
        appState.store.selectedTheme.colors
    }

    private var sortedEntries: [(date: String, text: String)] {
        journalStore.entries
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, text: $0.value) }
    }

    var body: some View {
        Group {
            if sortedEntries.isEmpty {
                ContentUnavailableView(
                    "日記がありません",
                    systemImage: "pencil",
                    description: Text("今日の格言を読んで、一句日記を書いてみましょう")
                )
            } else {
                List(sortedEntries, id: \.date) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(entry.date)
                            .font(.caption)
                            .foregroundStyle(colors.accent.opacity(0.7))
                        Text(entry.text)
                            .font(.body)
                            .foregroundStyle(colors.primaryText)
                            .lineLimit(4)
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(entry.date)の日記、\(entry.text)")
                }
            }
        }
        .navigationTitle("日記履歴")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        JournalHistoryView()
            .environment(AppState())
            .environment(JournalStore())
    }
}
