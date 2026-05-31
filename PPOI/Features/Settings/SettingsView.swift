import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    private let notificationService = NotificationService()

    /// 設定画面内の表示用（完了時に store へ反映）
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
                        selectionRow(
                            title: theme.label,
                            isSelected: selectedTheme == theme
                        ) {
                            selectedTheme = theme
                        }
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

                    Picker("通知時刻", selection: $notificationHour) {
                        ForEach(6..<23, id: \.self) { hour in
                            Text("\(hour):00").tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    NavigationLink {
                        FavoritesView()
                    } label: {
                        Label("お気に入り", systemImage: "heart")
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        applyAndDismiss()
                    }
                }
            }
            .onAppear {
                guard !didLoad else { return }
                selectedTheme = appState.store.selectedTheme
                fontVariant = appState.store.fontVariant
                notificationHour = appState.store.notificationHour
                notificationEnabled = appState.store.notificationEnabled
                didLoad = true
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
    }

    private func applyAndDismiss() {
        appState.store.selectedTheme = selectedTheme
        appState.store.fontVariant = fontVariant
        appState.store.notificationHour = notificationHour
        appState.store.notificationEnabled = notificationEnabled

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

/// 設定リスト行 — 押下中に背景ハイライト
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
}
