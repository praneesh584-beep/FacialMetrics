import SwiftUI

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ScannerStatusPanel(viewModel: viewModel)
                    GuidancePanel(stage: viewModel.stage, guidance: viewModel.guidance)
                    QualitySummary(viewModel: viewModel)

                    if let report = viewModel.report {
                        NavigationLink {
                            ResultsView(report: report)
                        } label: {
                            Label("View Results", systemImage: "chart.bar.xaxis")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                ScannerActionBar(viewModel: viewModel)
            }
        }
    }
}

private struct ScannerStatusPanel: View {
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(viewModel.isRunning ? "Camera active" : "Camera inactive", systemImage: viewModel.isRunning ? "camera.fill" : "camera")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(AppBranding.experimentalLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .accessibilityLabel("Scan progress")

            Text(viewModel.stage.title)
                .font(.title3.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }

    private var progress: Double {
        guard let index = ScanStage.allCases.firstIndex(of: viewModel.stage) else { return 0 }
        return Double(index) / Double(max(ScanStage.allCases.count - 1, 1))
    }
}

private struct GuidancePanel: View {
    let stage: ScanStage
    let guidance: String

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: symbol(for: stage))
                .font(.system(size: 50, weight: .regular))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text(guidance)
                .font(.title3.weight(.medium))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(stage.title). \(guidance)")
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

private struct QualitySummary: View {
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        HStack(spacing: 10) {
            MetricPill(title: "Accepted", value: "\(viewModel.acceptedFrameCount)")
            MetricPill(title: "Rejected", value: "\(viewModel.rejectedFrameCount)")
            MetricPill(title: "Quality", value: qualityText)
        }
    }

    private var qualityText: String {
        guard let score = viewModel.lastQuality?.score else { return "--" }
        return score.formatted(.number.precision(.fractionLength(2)))
    }
}

private struct ScannerActionBar: View {
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        VStack(spacing: 10) {
            Button {
                Task {
                    if viewModel.isRunning {
                        await viewModel.captureNextSample()
                    } else {
                        await viewModel.begin()
                    }
                }
            } label: {
                Label(primaryTitle, systemImage: primarySymbol)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.stage == .results)

            HStack(spacing: 10) {
                #if targetEnvironment(simulator)
                Button {
                    Task { await viewModel.runMockFlow() }
                } label: {
                    Label("Mock", systemImage: "forward.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                #endif

                Button(role: .cancel) {
                    viewModel.stop()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.isRunning)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(.regularMaterial)
    }

    private var primaryTitle: String {
        viewModel.isRunning ? "Continue Scan" : "Start Scanner"
    }

    private var primarySymbol: String {
        viewModel.isRunning ? "camera.metering.center.weighted" : "play.fill"
    }
}

private struct MetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}
