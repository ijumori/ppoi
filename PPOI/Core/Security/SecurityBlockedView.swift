import SwiftUI

/// Displayed when SecurityGuard detects an untrusted environment.
/// Blocks all app functionality (bank-level policy).
struct SecurityBlockedView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.red)

                Text("セキュリティ警告")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text("お使いのデバイス環境は安全でないと判断されました。\nアプリの利用を制限しています。")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 8) {
                    Text("考えられる原因:")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))

                    ForEach(reasons, id: \.self) { reason in
                        HStack(alignment: .top, spacing: 8) {
                            Text("・")
                            Text(reason)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }

    private var reasons: [String] {
        [
            "デバイスが脱獄（Jailbreak）されている",
            "デバッグツールが接続されている",
            "不正なライブラリが読み込まれている",
            "アプリが改ざんされている",
        ]
    }
}

#Preview {
    SecurityBlockedView()
}
