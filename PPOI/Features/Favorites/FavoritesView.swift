import SwiftUI

struct FavoritesView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            if appState.store.favorites.isEmpty {
                ContentUnavailableView(
                    "お気に入りはまだありません",
                    systemImage: "heart",
                    description: Text("ホームでハートを押すと、ここに保存されます。")
                )
            } else {
                ForEach(appState.store.favorites) { quote in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quote.displayDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(quote.text)
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { offsets in
                    appState.store.removeFavorites(at: offsets)
                }
            }
        }
        .navigationTitle("お気に入り")
        .navigationBarTitleDisplayMode(.inline)
    }

}

#Preview {
    NavigationStack {
        FavoritesView()
            .environment(AppState())
    }
}
