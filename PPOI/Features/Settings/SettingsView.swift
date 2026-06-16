import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(StoreManager.self) private var store
    @Environment(\.dismiss) private var dismiss

    private let notificationService = NotificationService()

    @State private var selectedTheme: AppTheme = .darkPremium
    @State private var fontVariant: FontVariant = .serif
    @State private var notificationHour: Int = 12
    @State private var notificationEnabled: Bool = true
    @State private var didLoad = false

    var body: some View {
        NavigationStack {
            Form {
                Section("表示テーマ") {
                    ForEach(AppTheme.allCases) { theme in
                        themeRow(theme)
                    }
                }

                Section("格言の字体") {
                    ForEach(FontVariant.allCases) { variant in
                        selectionRow(
                            title: variant.label,
                            isSelected: fontVariant == variant
                        ) {
                            fontVariant = variant
                        }
                    }
                }

                Section("通知") {
                    Toggle("プッシュ通知", isOn: $notificationEnabled)
                        .accessibilityLabel("プッシュ通知")
                        .accessibilityHint(notificationEnabled ? "オン" : "オフ")

                    Picker("通知時刻", selection: $notificationHour) {
                        ForEach(6 ..< 23, id: \.self) { hour in
                            Text("\(hour):00").tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityLabel("通知時刻: \(notificationHour)時")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        applyAndDismiss()
                    }
                    .accessibilityLabel("設定を保存して閉じる")
                }
            }
            .onAppear {
                guard !didLoad else { return }
                selectedTheme = appState.preferences.selectedTheme
                fontVariant = appState.preferences.fontVariant
                notificationHour = appState.preferences.notificationHour
                notificationEnabled = appState.preferences.notificationEnabled
                didLoad = true
            }
        }
    }

    @ViewBuilder
    private func themeRow(_ theme: AppTheme) -> some View {
        if theme.isStreakReward, !appState.rewards.hasUnlockedStreakTheme {
            HStack {
                Text(theme.label)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("7日連続で解放")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("\(theme.label)、7日連続閲覧で解放")
        } else if theme.isPremiumOnly, !store.isPurchased {
            HStack {
                Text(theme.label)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("プレミアム限定")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            .accessibilityLabel("\(theme.label)、プレミアム限定")
        } else {
            selectionRow(
                title: theme.label,
                isSelected: selectedTheme == theme
            ) {
                selectedTheme = theme
            }
        }
    }

    private func selectionRow(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                    .opacity(isSelected ? 1 : 0)
                    .accessibilityHidden(!isSelected)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsSelectionRowButtonStyle())
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func applyAndDismiss() {
        appState.preferences.selectedTheme = selectedTheme
        appState.preferences.fontVariant = fontVariant
        appState.preferences.notificationHour = notificationHour
        appState.preferences.notificationEnabled = notificationEnabled

        Task {
            if notificationEnabled {
                _ = await notificationService.requestAuthorization()
            }
            await notificationService.scheduleDailyNotification(
                hour: notificationHour,
                enabled: notificationEnabled
            )
        }

        dismiss()
    }
}

private struct SettingsSelectionRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? Color.primary.opacity(0.08)
                    : Color.clear
            )
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
        .environment(StoreManager.shared)
}
