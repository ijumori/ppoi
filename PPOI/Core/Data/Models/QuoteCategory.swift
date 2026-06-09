import Foundation

enum QuoteCategory: String, CaseIterable, Identifiable {
    case life
    case work
    case philosophy
    case humor

    var id: String { rawValue }

    var label: String {
        switch self {
        case .life: "人生"
        case .work: "仕事"
        case .philosophy: "哲学"
        case .humor: "ユーモア"
        }
    }

    /// QuoteTone とのマッピング（簡易フィルタ用）
    var tone: QuoteTone {
        switch self {
        case .humor: .humorous
        case .life, .work, .philosophy: .serious
        }
    }
}
