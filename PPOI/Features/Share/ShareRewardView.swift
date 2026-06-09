import SwiftUI

/// シェア完了後に表示する報酬オーバーレイ
struct ShareRewardView: View {
    let shareCount: Int
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(title.icon)
                .font(.system(size: 40))
            Text(title.name)
                .font(.headline.weight(.bold))
            Text("累計 \(shareCount) 回シェア")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("友達にもこの一句を")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
        .transition(.scale.combined(with: .opacity))
        .sensoryFeedback(.success, trigger: shareCount)
        .onTapGesture { onDismiss() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("シェア完了！累計\(shareCount)回。\(title.name)")
        .task {
            try? await Task.sleep(for: .seconds(2.5))
            onDismiss()
        }
    }

    private var title: (icon: String, name: String) {
        switch shareCount {
        case ...4: return ("📖", "格言見習い")
        case ...14: return ("📣", "格言の伝道師")
        case ...29: return ("🎓", "格言師範")
        default: return ("🧙", "格言仙人")
        }
    }
}
