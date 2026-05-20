import SwiftUI

struct ShareInputView: View {
    let quote: Quote
    let theme: AppTheme
    let fontVariant: FontVariant
    var onShareCompleted: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var reflection = ""
    @State private var showPreview = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("この格言、あなたはどう読んだ？")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top)

                TextField("考察を入力（任意）", text: $reflection, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Spacer()

                VStack(spacing: 12) {
                    if reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button("スキップして共有") {
                            presentShare(reflection: "")
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("プレビュー") {
                            showPreview = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("考察してシェアする")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .sheet(isPresented: $showPreview) {
                SharePreviewView(
                    quote: quote,
                    reflection: reflection,
                    theme: theme,
                    fontVariant: fontVariant,
                    onShareCompleted: onShareCompleted
                )
            }
        }
    }

    private func presentShare(reflection: String) {
        let text = ShareTextBuilder.build(reflection: reflection)
        var items: [Any] = [text]

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

#Preview {
    ShareInputView(
        quote: .placeholder,
        theme: .darkPremium,
        fontVariant: .serif
    )
}
