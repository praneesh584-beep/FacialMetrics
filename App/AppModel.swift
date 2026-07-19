import Combine
import Foundation

@MainActor
final class AppModel: ObservableObject {
    let diagnostics: DiagnosticBuffer
    let scanStore: ScanStore
    let captureProvider: FaceCaptureProvider
    let qualityEvaluator: ScanQualityEvaluator
    let measurementEngine: MeasurementEngine
    let scoringEngine: ScoringEngine
    let scannerViewModel: ScannerViewModel

    init(
        diagnostics: DiagnosticBuffer,
        scanStore: ScanStore,
        captureProvider: FaceCaptureProvider,
        qualityEvaluator: ScanQualityEvaluator,
        measurementEngine: MeasurementEngine,
        scoringEngine: ScoringEngine
    ) {
        self.diagnostics = diagnostics
        self.scanStore = scanStore
        self.captureProvider = captureProvider
        self.qualityEvaluator = qualityEvaluator
        self.measurementEngine = measurementEngine
        self.scoringEngine = scoringEngine
        self.scannerViewModel = ScannerViewModel(
            captureProvider: captureProvider,
            qualityEvaluator: qualityEvaluator,
            measurementEngine: measurementEngine,
            scoringEngine: scoringEngine,
            scanStore: scanStore,
            diagnostics: diagnostics
        )
    }

    static func bootstrap() -> AppModel {
        let diagnostics = DiagnosticBuffer(capacity: 300)
        let store = ScanStore(diagnostics: diagnostics)
        let evaluator = ScanQualityEvaluator(configuration: .initial)
        let measurement = MeasurementEngine()
        let scoring = MockScoringEngine()

        #if targetEnvironment(simulator) || FACEMETRIC_MOCK_CAPTURE
        let provider: FaceCaptureProvider = MockFaceCaptureProvider(scenario: .successfulGuidedScan, diagnostics: diagnostics)
        #else
        let provider: FaceCaptureProvider = ARKitFaceCaptureProvider(diagnostics: diagnostics)
        #endif

        diagnostics.record(.init(level: .info, category: "app", message: "App model bootstrapped"))
        return AppModel(
            diagnostics: diagnostics,
            scanStore: store,
            captureProvider: provider,
            qualityEvaluator: evaluator,
            measurementEngine: measurement,
            scoringEngine: scoring
        )
    }
}
