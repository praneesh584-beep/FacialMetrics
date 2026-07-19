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
        ScannerView(
            viewModel: appModel.scannerViewModel,
            store: appModel.scanStore,
            diagnostics: appModel.diagnostics
        )
    }
}
