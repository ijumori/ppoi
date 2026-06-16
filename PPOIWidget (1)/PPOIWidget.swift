import SwiftUI
import WidgetKit

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quoteText: String
    let quoteDate: String?
    let hasData: Bool

    static let preview = QuoteEntry(
        date: Date(),
        quoteText: "静寂の中にこそ、真の答えは眠っている",
        quoteDate: nil,
        hasData: true
    )

    static let empty = QuoteEntry(
        date: Date(),
        quoteText: "アプリを開いて、今日の一句を受け取ろう。",
        quoteDate: nil,
        hasData: false
    )
}

struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry { .preview }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let timeline = Timeline(entries: [currentEntry()], policy: .after(Self.nextJSTMidnight()))
        completion(timeline)
    }

    private func currentEntry() -> QuoteEntry {
        guard let snapshot = SharedQuoteStore.load() else { return .empty }
        return QuoteEntry(
            date: Date(),
            quoteText: snapshot.text,
            quoteDate: snapshot.date,
            hasData: true
        )
    }

    /// 次の JST 0:00（日替わりでタイムライン更新）
    static func nextJSTMidnight() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        let startOfToday = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? Date().addingTimeInterval(3600)
    }
}

struct PPOIWidgetEntryView: View {
    var entry: QuoteEntry

    var body: some View {
        VStack(spacing: 8) {
            Text("今日の「っぽい格言」")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(entry.quoteText)
                .font(.system(size: 15, weight: .medium, design: .serif))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
                .lineLimit(4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct PPOIWidget: Widget {
    private let kind = "PPOIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            PPOIWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("今日の格言")
        .description("今日の「っぽい格言」をホーム画面に表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct PPOIWidgetBundle: WidgetBundle {
    var body: some Widget {
        PPOIWidget()
    }
}

#Preview(as: .systemSmall) {
    PPOIWidget()
} timeline: {
    QuoteEntry.preview
    QuoteEntry.empty
}
