import SwiftUI

/// 1200×675 固定サイズの共有カード（ImageRenderer 用）
struct ShareCardExportView: View {
    let quote: Quote
    let reflection: String
    let theme: AppTheme
    let fontVariant: FontVariant

    private var colors: ThemeColors { theme.colors }

    /// 格言テキストの折り返し幅（ImageRenderer で明示幅がないと1行になる）
    private var quoteTextWidth: CGFloat { ShareImageSpec.width * 0.82 }

    var body: some View {
        ZStack {
            cardBackground

            VStack(spacing: 0) {
                Text(DateFormatter.jstDisplay.string(from: Date()))
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(colors.accent)
                    .padding(.top, 40)

                Spacer(minLength: 16)

                Text(quote.text)
                    .font(quoteFont)
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(quoteLineSpacing)
                    .frame(width: quoteTextWidth, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)

                if !reflection.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("私の考察：")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(colors.accent)
                        Text(reflection)
                            .font(.system(size: 32))
                            .foregroundStyle(colors.primaryText.opacity(0.9))
                            .lineSpacing(8)
                            .frame(width: quoteTextWidth, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 24)
                }

                Spacer(minLength: 16)

                HStack {
                    Text("#っぽい格言")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(colors.accent)
                    Spacer()
                    Text("っぽい格言・AI創作")
                        .font(.system(size: 24))
                        .foregroundStyle(colors.accent.opacity(0.75))
                }
                .padding(.horizontal, 56)
                .padding(.bottom, 36)
            }
        }
        .frame(width: ShareImageSpec.width, height: ShareImageSpec.height)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    @ViewBuilder
    private var cardBackground: some View {
        if let gradient = colors.gradient {
            gradient
        } else {
            colors.background
        }
    }

    private var quoteFont: Font {
        let design: Font.Design = fontVariant == .serif ? .serif : .default
        return .system(size: quoteFontSize, weight: .medium, design: design)
    }

    /// 文字数に応じてサイズ調整（長いほど少し小さく、短いほど大きく）
    private var quoteFontSize: CGFloat {
        let count = quote.text.count
        switch count {
        case ...12: return 80
        case ...18: return 72
        case ...26: return 64
        case ...34: return 56
        default: return 48
        }
    }

    private var quoteLineSpacing: CGFloat {
        quoteFontSize * 0.2
    }
}

#Preview {
    ShareCardExportView(
        quote: .placeholder,
        reflection: "",
        theme: .darkPremium,
        fontVariant: .serif
    )
}
