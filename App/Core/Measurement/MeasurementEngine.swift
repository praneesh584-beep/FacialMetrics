import Foundation

struct MeasurementEngine {
    func analyze(samples: [FaceFrameSample], quality: ScanQualityResult) -> MeasurementResult {
        let widths = samples.map { $0.mesh.boundingWidth }
        let heights = samples.map { $0.mesh.boundingHeight }
        let medianWidth = RobustStats.median(widths) ?? 0
        let medianHeight = RobustStats.median(heights) ?? 0
        let ratio = medianHeight > 0 ? medianWidth / medianHeight : 0
        let symmetry = symmetryBalance(samples: samples)
        let confidence: MeasurementConfidence = quality.score > 0.85 ? .high : (quality.score > 0.6 ? .medium : .low)

        return MeasurementResult(
            algorithmVersion: AppConfiguration.measurementAlgorithmVersion,
            values: [
                MeasurementValue(
                    id: "mesh_width_height_ratio",
                    definition: MeasurementDefinition(
                        id: "mesh_width_height_ratio",
                        name: "Mesh width-to-height ratio",
                        formula: "median(mesh width) / median(mesh height)",
                        unit: "ratio",
                        limitations: "Uses ARKit mesh bounds, not validated anatomical landmarks.",
                        algorithmVersion: AppConfiguration.measurementAlgorithmVersion,
                        physicallyValidated: false
                    ),
                    value: ratio,
                    confidence: confidence
                ),
                MeasurementValue(
                    id: "x_axis_vertex_balance",
                    definition: MeasurementDefinition(
                        id: "x_axis_vertex_balance",
                        name: "Left-right mesh balance",
                        formula: "1 - abs(left vertex count - right vertex count) / total vertices",
                        unit: "ratio",
                        limitations: "Descriptive geometry only. The facial midline is not validated.",
                        algorithmVersion: AppConfiguration.measurementAlgorithmVersion,
                        physicallyValidated: false
                    ),
                    value: symmetry,
                    confidence: confidence
                )
            ]
        )
    }

    func makeReport(samples: [FaceFrameSample], quality: ScanQualityResult, scoring: ScoringResult?) -> AnalysisReport {
        AnalysisReport(
            createdAt: Date(),
            quality: quality,
            measurements: analyze(samples: samples, quality: quality),
            scoring: scoring,
            sampleCount: samples.count,
            algorithmVersion: AppConfiguration.measurementAlgorithmVersion,
            limitations: [
                "Measurements are experimental.",
                "No attractiveness claim is made.",
                "Physical TrueDepth validation is pending."
            ]
        )
    }

    private func symmetryBalance(samples: [FaceFrameSample]) -> Double {
        let vertices = samples.flatMap { $0.mesh.vertices }
        guard !vertices.isEmpty else { return 0 }
        let left = vertices.filter { $0.x < 0 }.count
        let right = vertices.filter { $0.x > 0 }.count
        let total = max(left + right, 1)
        return max(0, 1 - Double(abs(left - right)) / Double(total))
    }
}
