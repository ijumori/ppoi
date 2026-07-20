import SwiftUI

/// テーマのグラデーション（定義があれば）を、無ければ単色を全画面背景として敷く。
/// QuoteView と QuoteDetailView で重複していた分岐を統合する。
///
/// 注: OnboardingView は単色のみで挙動が異なるため、この共通化の対象外。
struct ThemedBackground: View {
    let colors: ThemeColors

    var body: some View {
        if let gradient = colors.gradient {
            gradient.ignoresSafeArea()
        } else {
            colors.background.ignoresSafeArea()
        }
    }
}
