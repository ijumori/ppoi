import Foundation

/// 格言のIDとトーンに基づいて、偉人風の架空人物名を生成する
enum FakeAuthorGenerator {
    static func author(for quote: Quote) -> String {
        let pool = quote.tone == .humorous ? humorousAuthors : seriousAuthors
        let index = stableHash(of: quote.id) % pool.count
        return pool[index]
    }

    /// アプリ起動ごとにハッシュが変わらないよう djb2 ベースの安定ハッシュ
    private static func stableHash(of string: String) -> Int {
        var hash: UInt64 = 5381
        for byte in string.utf8 {
            hash = hash &* 33 &+ UInt64(byte)
        }
        return Int(hash % UInt64(Int.max))
    }

    private static let humorousAuthors = [
        "— 自称・哲学者 タナカ・ゲンイチロフ",
        "— 公園のベンチの賢者 スズキ・ヨシヒコ",
        "— 深夜のコンビニ前の哲人 イトウ・マサキーニ",
        "— 元・天才少年 ヤマモト・コウジスキー",
        "— 万年係長 キムラ・シュンスケ",
        "— 自販機の前で悟った男 コバヤシ・タクヤ",
        "— 昼寝の達人 オオタ・ケンジロフ",
        "— 通勤電車の思索家 ナカムラ・ユウキ",
        "— 退職済みの預言者 モリタ・ヒデオ",
        "— 二度寝の王 フクダ・マサヒコフ",
        "— 路地裏の詩人 ハセガワ・シンゴ",
        "— 存在しない哲学者 ニシイ・タカヒロフ",
    ]

    private static let seriousAuthors = [
        "— 無名の哲学者 ニシヤマ・テツロウ",
        "— 放浪の詩人 タカハシ・リョウ",
        "— 黎明の思想家 モリ・カズヒコ",
        "— 東方の賢者 フジワラ・ソウイチ",
        "— 孤高の隠者 アオキ・シンジ",
        "— 夕暮れの詩人 ハヤシ・ユウスケ",
        "— 沈黙の哲人 マツダ・ケイ",
        "— 山岳の修験者 カワムラ・ゲン",
        "— 遥かなる書の翁 イシカワ・トシオ",
        "— 静寂の学徒 オカダ・ヒロシ",
        "— 旅の思索家 ミヤザキ・ジュン",
        "— 暁の語り部 サカモト・レン",
    ]
}
