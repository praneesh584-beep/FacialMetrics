import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        TabView {
            ScannerView(viewModel: appModel.scannerViewModel)
                .tabItem { Label("Scan", systemImage: "viewfinder") }

            HistoryView(store: appModel.scanStore)
                .tabItem { Label("History", systemImage: "clock") }

            SettingsView(diagnostics: appModel.diagnostics, store: appModel.scanStore)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
