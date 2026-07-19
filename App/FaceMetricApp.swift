import SwiftUI

@main
struct FaceMetricApp: App {
    @StateObject private var appModel: AppModel

    init() {
        _appModel = StateObject(wrappedValue: AppModel.bootstrap())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appModel)
        }
    }
}
