import CoreImage.CIFilterBuiltins
import SwiftUI

/// 1200×675 固定サイズの共有カード（ImageRenderer 用）
struct ShareCardExportView: View {
    let quote: Quote
    let reflection: String
    let theme: AppTheme
    let fontVariant: FontVariant

    private var colors: ThemeColors {
        theme.colors
    }

    /// 格言テキストの折り返し幅（ImageRenderer で明示幅がないと1行になる）
    private var quoteTextWidth: CGFloat {
        ShareImageSpec.width * 0.82
    }

    private static let appStoreURL = "https://apps.apple.com/app/id6771264998"

    var body: some View {
        ZStack {
            cardBackground

            VStack(spacing: 0) {
                Text(quote.displayDate)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(colors.accent)
                    .padding(.top, 32)

                Spacer(minLength: 10)

                Text(quote.text)
                    .font(quoteFont)
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(quoteLineSpacing)
                    .frame(width: quoteTextWidth, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(FakeAuthorGenerator.author(for: quote))
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(colors.primaryText.opacity(0.55))
                    .padding(.top, 10)

                if !reflection.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("私の考察：")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(colors.accent)
                        Text(reflection)
                            .font(.system(size: 26))
                            .foregroundStyle(colors.primaryText.opacity(0.9))
                            .lineSpacing(6)
                            .frame(width: quoteTextWidth, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 14)
                }

                Spacer(minLength: 10)

                footerView
            }
        }
        .frame(width: ShareImageSpec.width, height: ShareImageSpec.height)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(alignment: .center, spacing: 16) {
            qrCodeView

            VStack(alignment: .leading, spacing: 4) {
                Text("AIが紡ぐ創作格言")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(colors.accent)
                HStack(spacing: 12) {
                    Text("#っぽい格言")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(colors.accent.opacity(0.8))
                    Text("明日には消える一句")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(colors.accent.opacity(0.55))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 48)
        .padding(.bottom, 28)
    }

    // MARK: - QR Code

    @ViewBuilder
    private var qrCodeView: some View {
        if let qrImage = Self.generateQRCode() {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.white)
                    .frame(width: 80, height: 80)
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 68, height: 68)
            }
        }
    }

    private static func generateQRCode() -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(appStoreURL.utf8)
        filter.correctionLevel = "M"

        guard let output = filter.outputImage else { return nil }
        let scale = 204.0 / output.extent.size.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - Background

    @ViewBuilder
    private var cardBackground: some View {
        if let gradient = colors.gradient {
            gradient
        } else {
            colors.background
        }
    }

    // MARK: - Quote Typography

    private var quoteFont: Font {
        let design: Font.Design = fontVariant == .serif ? .serif : .default
        return .system(size: quoteFontSize, weight: .medium, design: design)
    }

    /// 文字数に応じてサイズ調整（長いほど少し小さく、短いほど大きく）
    private var quoteFontSize: CGFloat {
        let count = quote.text.count
        if !reflection.isEmpty {
            // 考察付きの場合は全体的にコンパクト
            switch count {
            case ...12: return 64
            case ...18: return 56
            case ...26: return 48
            default: return 40
            }
        }
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

#Preview("No reflection") {
    ShareCardExportView(
        quote: .placeholder,
        reflection: "",
        theme: .darkPremium,
        fontVariant: .serif
    )
}

#Preview("With reflection") {
    ShareCardExportView(
        quote: .placeholder,
        reflection: "意味不明だけど、なぜか沁みる",
        theme: .pop,
        fontVariant: .serif
    )
}
