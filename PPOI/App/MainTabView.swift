import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var selectedTab: TabDestination = .today
    @State private var iPadSelection: TabDestination? = .today

    var body: some View {
        if sizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            QuoteView()
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }
                .tag(TabDestination.today)

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "books.vertical")
                }
                .tag(TabDestination.explore)

            MyPageView()
                .tabItem {
                    Label("My Page", systemImage: "person.crop.circle")
                }
                .tag(TabDestination.myPage)
        }
        .tint(appState.preferences.selectedTheme.colors.accent)
    }

    private var iPadLayout: some View {
        NavigationSplitView {
            List(selection: $iPadSelection) {
                Label("Today", systemImage: "sun.max")
                    .tag(TabDestination.today)
                Label("Explore", systemImage: "books.vertical")
                    .tag(TabDestination.explore)
                Label("My Page", systemImage: "person.crop.circle")
                    .tag(TabDestination.myPage)
            }
            .navigationTitle("っぽい格言")
        } detail: {
            switch iPadSelection {
            case .today, nil:
                QuoteView()
            case .explore:
                ExploreView()
            case .myPage:
                MyPageView()
            }
        }
        .tint(appState.preferences.selectedTheme.colors.accent)
    }
}

enum TabDestination: Hashable {
    case today, explore, myPage
}

#Preview {
    MainTabView()
        .environment(AppState())
        .environment(StoreManager.shared)
}
