import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(AppConfiguration.displayName)
                            .font(.largeTitle.weight(.semibold))
                            .accessibilityAddTraits(.isHeader)
                        Text(AppBranding.shortPrivacySummary)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        PrivacyRow(symbol: "lock.shield", title: "On-device processing", body: "The MVP keeps scan samples local and does not upload scans automatically.")
                        PrivacyRow(symbol: "camera.viewfinder", title: "Camera consent", body: "The front TrueDepth camera is used only after camera permission is granted.")
                        PrivacyRow(symbol: "square.and.arrow.up", title: "User-initiated export", body: "Diagnostics and scan summaries are shared only when you choose to export them.")
                        PrivacyRow(symbol: "exclamationmark.triangle", title: "Experimental measurements", body: "Results are geometry experiments, not medical advice or a scientific attractiveness rating.")
                    }

                    Button(action: onComplete) {
                        Label("Continue", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityHint("Opens the FaceMetric scanner and settings tabs.")
                }
                .padding()
            }
            .navigationTitle("Welcome")
        }
    }
}

private struct PrivacyRow: View {
    let symbol: String
    let title: String
    let body: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(body)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
