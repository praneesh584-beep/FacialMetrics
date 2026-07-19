import SwiftUI

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                ScannerStatusPanel(viewModel: viewModel)

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemBackground))
                    VStack(spacing: 16) {
                        Image(systemName: symbol(for: viewModel.stage))
                            .font(.system(size: 56, weight: .regular))
                            .foregroundStyle(.tint)
                            .accessibilityHidden(true)
                        Text(viewModel.stage.title)
                            .font(.title2.weight(.semibold))
                        Text(viewModel.guidance)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(0.82, contentMode: .fit)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(viewModel.stage.title). \(viewModel.guidance)")

                VStack(spacing: 12) {
                    Button {
                        Task { await viewModel.begin() }
                    } label: {
                        Label("Start Scanner", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        Task { await viewModel.captureNextSample() }
                    } label: {
                        Label("Capture Next Sample", systemImage: "camera.metering.center.weighted")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.stage == .results || viewModel.stage == .failed)

                    Button {
                        Task { await viewModel.runMockFlow() }
                    } label: {
                        Label("Run Mock Scan", systemImage: "forward.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(role: .cancel) {
                        viewModel.stop()
                    } label: {
                        Label("Stop Camera", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if let report = viewModel.report {
                    NavigationLink {
                        ResultsView(report: report)
                    } label: {
                        Label("View Results", systemImage: "chart.bar.xaxis")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Scanner")
        }
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

private struct ScannerStatusPanel: View {
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(viewModel.isRunning ? "Camera active" : "Camera inactive", systemImage: viewModel.isRunning ? "camera.fill" : "camera")
                Spacer()
                Text(AppBranding.experimentalLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .accessibilityLabel("Scan progress")

            HStack {
                MetricPill(title: "Accepted", value: "\(viewModel.acceptedFrameCount)")
                MetricPill(title: "Rejected", value: "\(viewModel.rejectedFrameCount)")
                if let score = viewModel.lastQuality?.score {
                    MetricPill(title: "Quality", value: score.formatted(.number.precision(.fractionLength(2))))
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }

    private var progress: Double {
        guard let index = ScanStage.allCases.firstIndex(of: viewModel.stage) else { return 0 }
        return Double(index) / Double(max(ScanStage.allCases.count - 1, 1))
    }
}

private struct MetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
