import SwiftUI

struct MyPageView: View {
    @Environment(AppState.self) private var appState
    @Environment(StoreManager.self) private var storeManager

    private var colors: ThemeColors { appState.store.selectedTheme.colors }

    var body: some View {
        NavigationStack {
            List {
                statsSection
                achievementsSection
                contentSection
                settingsSection
                premiumSection
                infoSection
            }
            .navigationTitle("My Page")
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        Section("統計") {
            HStack {
                statCard(
                    icon: "flame.fill",
                    value: "\(appState.store.currentStreak)",
                    label: "連続日数"
                )
                Spacer()
                statCard(
                    icon: "heart.fill",
                    value: "\(appState.store.favorites.count)",
                    label: "お気に入り"
                )
                Spacer()
                statCard(
                    icon: "square.and.arrow.up",
                    value: "\(appState.store.totalShareCount)",
                    label: "シェア回数"
                )
            }
            .padding(.vertical, 8)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("連続\(appState.store.currentStreak)日、お気に入り\(appState.store.favorites.count)件、シェア\(appState.store.totalShareCount)回")
        }
    }

    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(colors.accent)
            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        Section("実績") {
            achievementRow(
                icon: "flame",
                title: "7日連続閲覧",
                detail: "禅・ゴールドテーマ解放",
                unlocked: appState.store.hasUnlockedStreakTheme
            )
            achievementRow(
                icon: "crown",
                title: "30日連続閲覧",
                detail: "格言マスター称号獲得",
                unlocked: appState.store.hasEarnedMasterTitle
            )
        }
    }

    private func achievementRow(icon: String, title: String, detail: String, unlocked: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: unlocked ? "\(icon).fill" : icon)
                .font(.title3)
                .foregroundStyle(unlocked ? colors.accent : .secondary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if unlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "lock")
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel("\(title)、\(unlocked ? "達成済み" : "未達成")、\(detail)")
    }

    // MARK: - Content

    private var contentSection: some View {
        Section {
            NavigationLink {
                FavoritesView()
            } label: {
                Label("お気に入り", systemImage: "heart")
            }
            .accessibilityLabel("お気に入り一覧")

            NavigationLink {
                ArchiveView()
            } label: {
                Label("過去の格言", systemImage: "book")
            }
            .accessibilityLabel("過去の格言アーカイブ")
        }
    }

    // MARK: - Settings

    @State private var showSettings = false

    private var settingsSection: some View {
        Section("設定") {
            Button {
                showSettings = true
            } label: {
                Label("テーマ・通知・字体", systemImage: "gearshape")
                    .foregroundStyle(.primary)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .accessibilityLabel("テーマ、通知、字体の設定を変更")

            Button {
                InviteManager.invite(quote: nil)
            } label: {
                Label("友達に教える", systemImage: "person.badge.plus")
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("友達にアプリを教える")
        }
    }

    // MARK: - Premium

    private var premiumSection: some View {
        Section("プレミアム") {
            if storeManager.isPurchased {
                Label("購入済み（広告なし）", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .accessibilityLabel("プレミアム購入済み、広告なし")
            } else {
                NavigationLink {
                    PaywallView()
                } label: {
                    Label("広告を除去（買い切り）", systemImage: "crown")
                }
                .accessibilityLabel("プレミアムを購入して広告を除去")

                Button("購入を復元") {
                    Task { await storeManager.restore() }
                }
                .accessibilityLabel("過去の購入を復元")
            }
        }
    }

    // MARK: - Info

    private var infoSection: some View {
        Section("情報") {
            Link(destination: URL(string: "https://ijumori.github.io/ppoi/legal/privacy-policy.html")!) {
                Label("プライバシーポリシー", systemImage: "hand.raised")
            }
            .accessibilityLabel("プライバシーポリシーを開く")

            Link(destination: URL(string: "https://ijumori.github.io/ppoi/legal/terms-of-use.html")!) {
                Label("利用規約", systemImage: "doc.text")
            }
            .accessibilityLabel("利用規約を開く")
        }
    }
}

#Preview {
    MyPageView()
        .environment(AppState())
        .environment(StoreManager.shared)
}
