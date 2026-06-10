import SwiftUI

struct JournalEntryView: View {
    let date: String
    let colors: ThemeColors
    @Environment(JournalStore.self) private var journalStore

    @State private var text: String = ""
    @State private var isFocused = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "pencil.and.outline")
                    .foregroundStyle(colors.accent)
                Text("一句日記")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(colors.accent)
                Spacer()
                Text("\(text.count)/\(JournalStore.maxLength)")
                    .font(.caption2)
                    .foregroundStyle(colors.accent.opacity(0.5))
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty && !isFocused {
                    Text("今日の一句に思うこと…")
                        .font(.subheadline)
                        .foregroundStyle(colors.primaryText.opacity(0.35))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $text)
                    .font(.subheadline)
                    .foregroundStyle(colors.primaryText)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 72, maxHeight: 120)
                    .onChange(of: text) { _, newValue in
                        if newValue.count > JournalStore.maxLength {
                            text = String(newValue.prefix(JournalStore.maxLength))
                        }
                        journalStore.save(text: text, for: date)
                    }
                    .onTapGesture { isFocused = true }
            }
            .padding(10)
            .background(colors.accent.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .onAppear {
            text = journalStore.entry(for: date)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("一句日記")
    }
}

#Preview {
    JournalEntryView(date: "2026-06-11", colors: AppTheme.darkPremium.colors)
        .environment(JournalStore())
        .padding()
        .background(Color.black)
}
