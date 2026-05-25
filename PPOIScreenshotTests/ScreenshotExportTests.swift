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

    private func exportDeviceScreen<V: View>(
        filename: String,
        to directory: URL,
        @ViewBuilder content: () -> V
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

    private var colors: ThemeColors { theme.colors }

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
                    .lineLimit(3...6)
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
