import SwiftUI

struct ResultsView: View {
    let report: AnalysisReport

    var body: some View {
        List {
            Section {
                LabeledContent("Created", value: report.createdAt.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Samples", value: "\(report.sampleCount)")
                LabeledContent("Quality", value: report.quality.score.formatted(.number.precision(.fractionLength(2))))
                LabeledContent("Algorithm", value: report.algorithmVersion)
            } header: {
                Text(AppBranding.experimentalLabel)
            } footer: {
                Text("These results are experimental geometry summaries and are not medical advice or a validated attractiveness rating.")
            }

            Section("Measurements") {
                ForEach(report.measurements.values) { measurement in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(measurement.definition.name)
                                .font(.headline)
                            Spacer()
                            Text(measurement.value.formatted(.number.precision(.fractionLength(3))))
                                .font(.headline.monospacedDigit())
                        }
                        Text(measurement.definition.limitations)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Confidence: \(measurement.confidence.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            if let scoring = report.scoring {
                Section("Scoring Boundary") {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent(scoring.label, value: scoring.value?.formatted(.number.precision(.fractionLength(3))) ?? "Hidden")
                        Text(scoring.explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Known Limitations") {
                ForEach(report.limitations, id: \.self) { limitation in
                    Label(limitation, systemImage: "info.circle")
                }
            }
        }
        .navigationTitle("Results")
    }
}
