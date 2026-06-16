import Foundation

struct Quote: Identifiable, Equatable, Codable, Hashable {
    let id: String
    let date: String
    let text: String
    let tone: QuoteTone
    var interpretation: String?
    var category: QuoteCategory?
    var question: String?

    /// "yyyy-MM-dd" → "yyyy年M月d日" に変換。失敗時はそのまま返す。
    var displayDate: String {
        guard let parsed = DateFormatter.jstDate.date(from: date) else { return date }
        return DateFormatter.jstDisplay.string(from: parsed)
    }

    static let placeholder = Quote(
        id: "placeholder",
        date: DateFormatter.jstDate.string(from: Date()),
        text: "静寂の中にこそ、真の答えは眠っている",
        tone: .serious
    )
}

enum QuoteTone: String, Codable {
    case humorous
    case serious
}

// DateFormatter.jstDate / jstDisplay は Core/Utilities/JSTDate.swift で定義
