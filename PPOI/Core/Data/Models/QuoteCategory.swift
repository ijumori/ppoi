import Foundation

enum QuoteCategory: String, CaseIterable, Identifiable, Codable {
    case life        // 人生
    case work        // 仕事
    case philosophy  // 哲学
    case humor       // ユーモア
    case love        // 愛・人間関係
    case growth      // 成長・挑戦

    var id: String { rawValue }

    var label: String {
        switch self {
        case .life:       "人生"
        case .work:       "仕事"
        case .philosophy: "哲学"
        case .humor:      "ユーモア"
        case .love:       "愛"
        case .growth:     "成長"
        }
    }

    var icon: String {
        switch self {
        case .life:       "leaf"
        case .work:       "briefcase"
        case .philosophy: "brain"
        case .humor:      "face.smiling"
        case .love:       "heart"
        case .growth:     "arrow.up.circle"
        }
    }
}
