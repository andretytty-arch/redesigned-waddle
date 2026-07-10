import SwiftUI

@main
struct TapVerseApp: App {
    @State private var store = GameStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.dark)
                .sheet(
                    item: Binding(
                        get: { store.presentedSheet },
                        set: { store.presentedSheet = $0 }
                    )
                ) { destination in
                    switch destination {
                    case .offlineReward:
                        OfflineRewardSheet()
                            .environment(store)
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    case .dailyReward:
                        DailyRewardSheet()
                            .environment(store)
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    case .prestige:
                        PrestigeSheet()
                            .environment(store)
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                    }
                }
                .task { store.start() }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        store.handleBecameActive()
                    case .background, .inactive:
                        store.stop()
                    @unknown default:
                        break
                    }
                }
        }
    }
}

struct RootView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        TabView {
            NavigationStack { PlayView() }
                .tabItem { Label("Играть", systemImage: "hand.tap.fill") }

            NavigationStack { UpgradesView() }
                .tabItem { Label("Улучшения", systemImage: "arrow.up.circle.fill") }

            NavigationStack { MissionsView() }
                .tabItem { Label("Задания", systemImage: "checklist") }

            NavigationStack { SocialView() }
                .tabItem { Label("Друзья", systemImage: "person.3.fill") }

            NavigationStack { ProfileView() }
                .tabItem { Label("Профиль", systemImage: "person.crop.circle.fill") }
        }
        .tint(store.selectedTheme.colors.last ?? .white)
    }
}
