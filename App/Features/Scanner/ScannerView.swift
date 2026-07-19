import SwiftUI

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    let store: ScanStore
    let diagnostics: DiagnosticBuffer

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                FaceMeshPreview(sample: viewModel.latestSample)
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        .black.opacity(0.70),
                        .clear,
                        .black.opacity(0.82)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    HeaderOverlay(viewModel: viewModel)
                    Spacer(minLength: 20)
                    BottomScanPanel(viewModel: viewModel)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 14)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(AppConfiguration.displayName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        HistoryView(store: store)
                    } label: {
                        Image(systemName: "clock")
                    }
                    .accessibilityLabel("Scan history")

                    NavigationLink {
                        DiagnosticsView(buffer: diagnostics)
                    } label: {
                        Image(systemName: "stethoscope")
                    }
                    .accessibilityLabel("Diagnostics")
                }
            }
        }
    }
}

private struct HeaderOverlay: View {
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                StatusDot(isActive: viewModel.isRunning)
                Text(viewModel.isRunning ? "TrueDepth active" : "Ready")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Text(AppBranding.experimentalLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))
            }

            ProgressView(value: progress)
                .tint(.cyan)
                .accessibilityLabel("Scan progress")

            HStack(spacing: 10) {
                ScannerMetric(title: "Frames", value: "\(viewModel.acceptedFrameCount)")
                ScannerMetric(title: "Rejected", value: "\(viewModel.rejectedFrameCount)")
                ScannerMetric(title: "Quality", value: qualityText)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
    }

    private var progress: Double {
        guard let index = ScanStage.allCases.firstIndex(of: viewModel.stage) else { return 0 }
        return Double(index) / Double(max(ScanStage.allCases.count - 1, 1))
    }

    private var qualityText: String {
        guard let score = viewModel.lastQuality?.score else { return "--" }
        return score.formatted(.number.precision(.fractionLength(2)))
    }
}

private struct BottomScanPanel: View {
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: symbol(for: viewModel.stage))
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.cyan)
                    .frame(width: 34)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.stage.title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(viewModel.guidance)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.76))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if viewModel.latestSample == nil {
                Text("Your colored 3D face mesh appears here as soon as TrueDepth tracking starts.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.62))
            }

            HStack(spacing: 10) {
                Button {
                    Task { await viewModel.runGuidedScan() }
                } label: {
                    Label(primaryTitle, systemImage: primarySymbol)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.isAutoScanning || viewModel.stage == .results)

                Button(role: .cancel) {
                    viewModel.stop()
                } label: {
                    Image(systemName: "stop.fill")
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.bordered)
                .tint(.white)
                .disabled(!viewModel.isRunning)
                .accessibilityLabel("Stop scan")
            }

                    if let report = viewModel.report {
                        NavigationLink {
                            ResultsView(report: report, previewSample: viewModel.latestSample)
                        } label: {
                            Label("View Results", systemImage: "chart.bar.xaxis")
                                .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.cyan)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
    }

    private var primaryTitle: String {
        if viewModel.isAutoScanning {
            return "Scanning"
        }
        return viewModel.isRunning ? "Continue" : "Start TrueDepth"
    }

    private var primarySymbol: String {
        viewModel.isRunning ? "viewfinder" : "play.fill"
    }

    private func symbol(for stage: ScanStage) -> String {
        switch stage {
        case .unsupportedDevice, .failed:
            return "exclamationmark.triangle"
        case .permission, .permissionDenied:
            return "camera.badge.ellipsis"
        case .results:
            return "checkmark.seal"
        case .turnLeft:
            return "arrow.turn.up.left"
        case .turnRight:
            return "arrow.turn.up.right"
        default:
            return "face.smiling"
        }
    }
}

private struct ScannerMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.58))
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StatusDot: View {
    let isActive: Bool

    var body: some View {
        Circle()
            .fill(isActive ? Color.green : Color.gray)
            .frame(width: 9, height: 9)
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.65), lineWidth: 1)
            )
            .accessibilityHidden(true)
    }
}
