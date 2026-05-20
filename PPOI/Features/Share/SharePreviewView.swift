import SwiftUI

struct SharePreviewView: View {
    let quote: Quote
    let reflection: String
    let theme: AppTheme
    let fontVariant: FontVariant
    var onShareCompleted: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    private var colors: ThemeColors { theme.colors }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ShareCardPreviewView(
                    quote: quote,
                    reflection: reflection,
                    theme: theme,
                    fontVariant: fontVariant
                )
                .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text("投稿テキスト")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(shareText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)

                Button("𝕏で共有") {
                    presentShare()
                }
                .buttonStyle(.borderedProminent)
                .tint(colors.button)

                Spacer()
            }
            .navigationTitle("プレビュー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("戻る") { dismiss() }
                }
            }
        }
    }

    private var shareText: String {
        ShareTextBuilder.build(reflection: reflection)
    }

    private func presentShare() {
        var items: [Any] = [shareText]

        if let image = ShareImageRenderer.render(
            quote: quote,
            reflection: reflection,
            theme: theme,
            fontVariant: fontVariant
        ) {
            items.append(image)
        }

        ShareActivityPresenter.present(items: items) { completed in
            dismiss()
            if completed {
                onShareCompleted?()
            }
        }
    }
}

/// 画面内プレビュー用（16:9 アスペクト比）
struct ShareCardPreviewView: View {
    let quote: Quote
    let reflection: String
    let theme: AppTheme
    let fontVariant: FontVariant

    var body: some View {
        ShareCardExportView(
            quote: quote,
            reflection: reflection,
            theme: theme,
            fontVariant: fontVariant
        )
        .aspectRatio(ShareImageSpec.aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.colors.accent.opacity(0.3), lineWidth: 1)
        }
    }
}

#Preview {
    SharePreviewView(
        quote: .placeholder,
        reflection: "意味不明だけど、なぜか沁みる…",
        theme: .darkPremium,
        fontVariant: .serif
    )
}
