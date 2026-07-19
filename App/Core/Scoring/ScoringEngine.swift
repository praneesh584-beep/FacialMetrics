import Foundation

protocol ScoringEngine {
    func score(measurements: MeasurementResult, scanQuality: ScanQualityResult) async throws -> ScoringResult
}

struct MockScoringEngine: ScoringEngine {
    func score(measurements: MeasurementResult, scanQuality: ScanQualityResult) async throws -> ScoringResult {
        let measurementComponent = measurements.values.map(\.value).reduce(0, +)
        let bounded = min(max((measurementComponent / Double(max(measurements.values.count, 1))) * scanQuality.score, 0), 1)
        return ScoringResult(
            algorithmVersion: AppConfiguration.scoringAlgorithmVersion,
            label: "Demo score",
            value: bounded,
            isDemo: true,
            isScientificallyValidated: false,
            isEnabledByDefault: false,
            explanation: "Development-only deterministic score. Not scientifically validated and not a measure of personal worth."
        )
    }
}
