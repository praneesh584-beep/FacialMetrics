import SwiftUI

@main
struct FaceMetricApp: App {
    @StateObject private var appModel = AppModel.bootstrap()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appModel)
        }
    }
}
