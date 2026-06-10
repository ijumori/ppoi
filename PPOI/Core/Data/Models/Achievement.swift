import Foundation

enum Achievement: String, CaseIterable, Identifiable {
    // 既存（ストリーク）
    case streakTheme    // 7日連続
    case masterTitle    // 30日連続
    // 新規
    case firstFavorite  // 初お気に入り
    case firstShare     // 初シェア
    case firstJournal   // 初日記
    case explorer       // 10件閲覧
    case voter7         // 7日投票
    case sharer5        // 5回シェア

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .streakTheme:   "flame"
        case .masterTitle:   "crown"
        case .firstFavorite: "heart"
        case .firstShare:    "square.and.arrow.up"
        case .firstJournal:  "pencil"
        case .explorer:      "books.vertical"
        case .voter7:        "hand.thumbsup"
        case .sharer5:       "paperplane"
        }
    }

    var title: String {
        switch self {
        case .streakTheme:   "7日連続閲覧"
        case .masterTitle:   "30日連続閲覧"
        case .firstFavorite: "初お気に入り"
        case .firstShare:    "初シェア"
        case .firstJournal:  "初日記"
        case .explorer:      "格言探索家"
        case .voter7:        "7日連続投票"
        case .sharer5:       "シェア5回達成"
        }
    }

    var detail: String {
        switch self {
        case .streakTheme:   "禅・ゴールドテーマ解放"
        case .masterTitle:   "格言マスター称号獲得"
        case .firstFavorite: "初めて格言をお気に入りに追加"
        case .firstShare:    "初めてXにシェア"
        case .firstJournal:  "初めて一句日記を書く"
        case .explorer:      "Exploreで10件の格言を閲覧"
        case .voter7:        "7日間連続で投票"
        case .sharer5:       "合計5回シェア"
        }
    }
}
