import Foundation

struct Quote: Identifiable, Equatable, Codable {
    let id: String
    let date: String
    let text: String
    let tone: QuoteTone

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

extension DateFormatter {
    static let jstDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let jstDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }()
}
