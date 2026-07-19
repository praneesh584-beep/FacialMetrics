import SwiftUI

struct SettingsView: View {
    @ObservedObject var diagnostics: DiagnosticBuffer
    let store: ScanStore
    @State private var deleteAllConfirmation = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            List {
                Section("App") {
                    LabeledContent("Name", value: AppConfiguration.displayName)
                    LabeledContent("Version", value: AppConfiguration.appVersion)
                    LabeledContent("Bundle ID", value: AppConfiguration.placeholderBundleIdentifier)
                }

                Section("Privacy") {
                    Text(PrivacyCopy.scanConsent)
                    Button(role: .destructive) {
                        deleteAllConfirmation = true
                    } label: {
                        Label("Delete All Scans", systemImage: "trash")
                    }
                }

                Section("Diagnostics") {
                    NavigationLink {
                        DiagnosticsView(buffer: diagnostics)
                    } label: {
                        Label("Open Diagnostics", systemImage: "stethoscope")
                    }
                    LabeledContent("Buffered Events", value: "\(diagnostics.events.count)")
                }

                if let message {
                    Section {
                        Text(message)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all scans?", isPresented: $deleteAllConfirmation, titleVisibility: .visible) {
                Button("Delete All Scans", role: .destructive) {
                    do {
                        try store.deleteAll()
                        message = "All local scans were deleted."
                    } catch {
                        message = error.localizedDescription
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes local scan summaries from this device.")
            }
        }
    }
}
