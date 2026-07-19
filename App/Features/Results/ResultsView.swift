import SwiftUI

struct ResultsView: View {
    let report: AnalysisReport
    var previewSample: FaceFrameSample? = nil

    var body: some View {
        List {
            if let previewSample {
                Section("3D Mesh") {
                    FaceMeshPreview(sample: previewSample)
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .listRowInsets(EdgeInsets())
                } footer: {
                    Text("This is the captured ARKit face mesh, rendered locally on device.")
                }
            }

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

            Section("Known Limitations") {
                ForEach(report.limitations, id: \.self) { limitation in
                    Label(limitation, systemImage: "info.circle")
                }
            }
        }
        .navigationTitle("Results")
    }
}
