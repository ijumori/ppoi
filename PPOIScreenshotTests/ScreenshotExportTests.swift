import SwiftUI
import XCTest
@testable import PPOI

/// App Store / docs 用 PNG を書き出す（シミュレータ上で実行）
@MainActor
final class ScreenshotExportTests: XCTestCase {
    private let quote = Quote.placeholder
    private let reflection = "意味不明だけど、なぜか沁みる…"
    private let theme = AppTheme.darkPremium
    private let fontVariant = FontVariant.serif

    /// iPhone 15 Pro Max 論理サイズ → 1290×2796 @3x
    private let deviceWidth: CGFloat = 430
    private let deviceHeight: CGFloat = 932
    private let exportScale: CGFloat = 3

    /// iPad 12.9" 論理サイズ → 2048×2732 @2x（App Store の iPad 必須サイズ）
    private let iPadWidth: CGFloat = 1024
    private let iPadHeight: CGFloat = 1366
    private let iPadScale: CGFloat = 2

    func testExportShareScreenshots() throws {
        let outputDir = Self.outputDirectory()
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        try exportShareCard(
            reflection: reflection,
            filename: "04-share-card-with-reflection.png",
            to: outputDir
        )
        try exportShareCard(
            reflection: "",
            filename: "05-share-card-quote-only.png",
            to: outputDir
        )
        try exportDeviceScreen(
            filename: "06-share-preview.png",
            to: outputDir
        ) {
            SharePreviewScreenshotView(
                quote: quote,
                reflection: reflection,
                theme: theme,
                fontVariant: fontVariant
            )
        }
        try exportDeviceScreen(
            filename: "07-share-input.png",
            to: outputDir
        ) {
            ShareInputScreenshotView(reflection: reflection, theme: theme)
        }

        print("[PPOIScreenshotTests] Exported to \(outputDir.path)")
    }

    /// iPad 用スクリーンショット（App Store 提出に必須）
    func testExportIPadScreenshots() throws {
        let outputDir = Self.outputDirectory()
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        try exportIPadScreen(filename: "ipad-01-today.png", to: outputDir) {
            IPadTodayScreenshotView(quote: quote, theme: theme, fontVariant: fontVariant)
        }
        try exportIPadScreen(filename: "ipad-02-explore.png", to: outputDir) {
            IPadExploreScreenshotView(theme: theme)
        }
        try exportIPadScreen(filename: "ipad-03-share.png", to: outputDir) {
            SharePreviewScreenshotView(
                quote: quote,
                reflection: reflection,
                theme: theme,
                fontVariant: fontVariant
            )
        }

        print("[PPOIScreenshotTests] iPad exported to \(outputDir.path)")
    }

    private func exportIPadScreen(
        filename: String,
        to directory: URL,
        @ViewBuilder content: () -> some View
    ) throws {
        let view = content()
            .frame(width: iPadWidth, height: iPadHeight)
            .background(Color(.systemBackground))

        let renderer = ImageRenderer(content: view)
        renderer.scale = iPadScale

        guard let image = renderer.uiImage, let data = image.pngData() else {
            XCTFail("iPad screen render failed: \(filename)")
            return
        }
        try data.write(to: directory.appendingPathComponent(filename))
    }

    private func exportShareCard(
        reflection: String,
        filename: String,
        to directory: URL
    ) throws {
        guard let image = ShareImageRenderer.render(
            quote: quote,
            reflection: reflection,
            theme: theme,
            fontVariant: fontVariant
        ),
            let data = image.pngData()
        else {
            XCTFail("Share card render failed: \(filename)")
            return
        }
        try data.write(to: directory.appendingPathComponent(filename))
    }

    private func exportDeviceScreen(
        filename: String,
        to directory: URL,
        @ViewBuilder content: () -> some View
    ) throws {
        let view = content()
            .frame(width: deviceWidth, height: deviceHeight)
            .background(Color(.systemBackground))

        let renderer = ImageRenderer(content: view)
        renderer.scale = exportScale

        guard let image = renderer.uiImage, let data = image.pngData() else {
            XCTFail("Device screen render failed: \(filename)")
            return
        }
        try data.write(to: directory.appendingPathComponent(filename))
    }

    private static func outputDirectory() -> URL {
        if let env = ProcessInfo.processInfo.environment["SCREENSHOT_OUTPUT_DIR"] {
            return URL(fileURLWithPath: env, isDirectory: true)
        }
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return repoRoot.appendingPathComponent("docs/screenshots", isDirectory: true)
    }
}

/// プレビュー画面（ImageRenderer 用・NavigationStack なし）
private struct SharePreviewScreenshotView: View {
    let quote: Quote
    let reflection: String
    let theme: AppTheme
    let fontVariant: FontVariant

    private var colors: ThemeColors {
        theme.colors
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenshotNavBar(title: "プレビュー", leading: "戻る")

            VStack(spacing: 24) {
                ShareCardPreviewView(
                    quote: quote,
                    reflection: reflection,
                    theme: theme,
                    fontVariant: fontVariant
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("投稿テキスト")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(ShareTextBuilder.build(reflection: reflection))
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 20)

                Button("𝕏で共有") {}
                    .buttonStyle(.borderedProminent)
                    .tint(colors.button)
                    .padding(.horizontal, 20)

                Spacer(minLength: 0)
            }
        }
        .background(Color(.systemBackground))
    }
}

/// 考察入力画面（TextField に文面を入れた状態）
private struct ShareInputScreenshotView: View {
    let reflection: String
    let theme: AppTheme

    var body: some View {
        VStack(spacing: 0) {
            ScreenshotNavBar(title: "考察してシェアする", leading: "キャンセル")

            VStack(spacing: 24) {
                Text("この格言、あなたはどう読んだ？")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 16)

                TextField("考察を入力（任意）", text: .constant(reflection), axis: .vertical)
                    .lineLimit(3 ... 6)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 20)

                Spacer(minLength: 0)

                Button("プレビュー") {}
                    .buttonStyle(.borderedProminent)
                    .tint(theme.colors.button)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .background(Color(.systemBackground))
    }
}

private struct ScreenshotNavBar: View {
    let title: String
    let leading: String

    var body: some View {
        ZStack {
            Text(title)
                .font(.headline)
            HStack {
                Text(leading)
                    .font(.body)
                    .foregroundStyle(Color.accentColor)
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 44)
        .padding(.top, 47)
        .background(Color(.systemBackground))
    }
}

/// iPad: 今日の格言 + AI解読 + 今日の問い（機能を示す静的モック）
private struct IPadTodayScreenshotView: View {
    let quote: Quote
    let theme: AppTheme
    let fontVariant: FontVariant

    private var colors: ThemeColors {
        theme.colors
    }

    var body: some View {
        ZStack {
            ThemedBackground(colors: colors)

            VStack(spacing: 36) {
                Spacer()

                Text(AppStrings.creativeQuoteCredit)
                    .font(.title3)
                    .foregroundStyle(colors.accent.opacity(0.85))

                Text(quote.text)
                    .font(fontVariant.quoteFont(size: 46))
                    .foregroundStyle(colors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 100)

                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "lightbulb")
                            .foregroundStyle(colors.accent)
                        Text("AI解読")
                            .font(.headline)
                            .foregroundStyle(colors.accent)
                    }
                    Text("計画通りにいかない偶然の出会いにこそ、真の成長の種が潜んでいる——そんな読み方もできる一句です。")
                        .font(.title3)
                        .foregroundStyle(colors.primaryText.opacity(0.85))
                        .lineSpacing(6)
                }
                .padding(28)
                .frame(maxWidth: 720, alignment: .leading)
                .background(colors.accent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Radius.xl))

                HStack(spacing: 10) {
                    Image(systemName: "questionmark.bubble")
                        .foregroundStyle(colors.accent)
                    Text("今日の問い：この一句を自分の仕事に当てはめると？")
                        .font(.body)
                        .foregroundStyle(colors.primaryText.opacity(0.8))
                }

                Spacer()
            }
            .padding(48)
        }
    }
}

/// iPad: カテゴリ別ブラウジング + 週間ランキング（機能を示す静的モック）
private struct IPadExploreScreenshotView: View {
    let theme: AppTheme

    private var colors: ThemeColors {
        theme.colors
    }

    private let categories = ["人生", "仕事", "恋愛", "笑い", "哲学", "孤独"]
    private let ranking = [
        "静寂の中にこそ、真の答えは眠っている。",
        "急ぐ心は、いちばんの近道を見失う。",
        "笑いとは、昨日の自分への小さな赦しだ。",
    ]

    var body: some View {
        ZStack {
            ThemedBackground(colors: colors)

            VStack(alignment: .leading, spacing: 28) {
                Text("さがす")
                    .font(.largeTitle.bold())
                    .foregroundStyle(colors.primaryText)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(categories, id: \.self) { c in
                        Text(c)
                            .font(.title3.weight(.medium))
                            .foregroundStyle(colors.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(colors.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: Radius.l))
                    }
                }

                Text("週間ランキング")
                    .font(.title2.bold())
                    .foregroundStyle(colors.primaryText)
                    .padding(.top, 8)

                ForEach(Array(ranking.enumerated()), id: \.offset) { index, text in
                    HStack(spacing: 16) {
                        Text("\(index + 1)")
                            .font(.largeTitle.bold())
                            .foregroundStyle(colors.accent)
                            .frame(width: 52)
                        Text(text)
                            .font(.title3)
                            .foregroundStyle(colors.primaryText.opacity(0.9))
                        Spacer()
                    }
                    .padding(22)
                    .background(colors.accent.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.l))
                }

                Spacer()
            }
            .padding(56)
        }
    }
}
