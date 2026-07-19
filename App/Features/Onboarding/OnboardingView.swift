import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(AppConfiguration.displayName)
                            .font(.title.weight(.semibold))
                            .accessibilityAddTraits(.isHeader)
                        Text(AppBranding.shortPrivacySummary)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 10) {
                        PrivacyRow(symbol: "lock.shield", title: "Local scans", detail: "Scan samples stay on this device.")
                        PrivacyRow(symbol: "camera.viewfinder", title: "Camera consent", detail: "The TrueDepth camera starts only after permission.")
                        PrivacyRow(symbol: "square.and.arrow.up", title: "Exports", detail: "Diagnostics are shared only when you choose.")
                        PrivacyRow(symbol: "exclamationmark.triangle", title: "Experimental", detail: "Results are not medical advice or a validated rating.")
                    }

                    Button(action: onComplete) {
                        Label("Continue", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityHint("Opens the FaceMetric scanner and settings tabs.")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct PrivacyRow: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(.tint)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}
