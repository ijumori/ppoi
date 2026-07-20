import SwiftUI

extension FontVariant {
    /// 対応する SwiftUI の `Font.Design`。
    var fontDesign: Font.Design {
        switch self {
        case .serif: .serif
        case .default: .default
        }
    }

    /// 格言表示用のシステムフォント。size 以外は共通。
    func quoteFont(size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: fontDesign)
    }
}
