import Combine
import Foundation

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published private(set) var stage: ScanStage = .privacyExplanation
    @Published private(set) var guidance = AppBranding.shortPrivacySummary
    @Published private(set) var lastQuality: ScanQualityResult?
    @Published private(set) var report: AnalysisReport?
    @Published private(set) var isRunning = false
    @Published private(set) var isAutoScanning = false
    @Published private(set) var latestSample: FaceFrameSample?
    @Published private(set) var acceptedFrameCount = 0
    @Published private(set) var rejectedFrameCount = 0

    private let captureProvider: FaceCaptureProvider
    private let qualityEvaluator: ScanQualityEvaluator
    private let measurementEngine: MeasurementEngine
    private let scoringEngine: ScoringEngine
    private let scanStore: ScanStore
    private let diagnostics: DiagnosticBuffer
    private var machine = ScannerStateMachine()
    private var previousSample: FaceFrameSample?

    init(
        captureProvider: FaceCaptureProvider,
        qualityEvaluator: ScanQualityEvaluator,
        measurementEngine: MeasurementEngine,
        scoringEngine: ScoringEngine,
        scanStore: ScanStore,
        diagnostics: DiagnosticBuffer
    ) {
        self.captureProvider = captureProvider
        self.qualityEvaluator = qualityEvaluator
        self.measurementEngine = measurementEngine
        self.scoringEngine = scoringEngine
        self.scanStore = scanStore
        self.diagnostics = diagnostics
        syncFromMachine()
    }

    func begin() async {
        report = nil
        machine = ScannerStateMachine()
        previousSample = nil
        latestSample = nil
        acceptedFrameCount = 0
        rejectedFrameCount = 0

        guard captureProvider.isSupported else {
            machine.markUnsupported()
            guidance = "This device does not report AR face tracking support."
            diagnostics.record(.init(level: .warning, category: "scanner", message: "Unsupported device"))
            syncFromMachine()
            return
        }

        machine.beginSupportedFlow()
        syncFromMachine()

        let granted = await captureProvider.requestPermission()
        guard granted else {
            machine.markPermissionDenied()
            guidance = "Camera permission is required. You can enable it in iOS Settings."
            diagnostics.record(.init(level: .warning, category: "scanner", message: "Camera permission denied"))
            syncFromMachine()
            return
        }

        do {
            try await captureProvider.start()
            isRunning = true
            machine.beginScanning()
            guidance = "Center your face and hold steady."
            syncFromMachine()
        } catch {
            machine.markFailed()
            guidance = error.localizedDescription
            diagnostics.record(.init(level: .error, category: "scanner", message: "Start failed: \(error.localizedDescription)"))
            syncFromMachine()
        }
    }

    func captureNextSample() async {
        guard isRunning else {
            await begin()
            return
        }
        do {
            let sample = try await captureProvider.captureStableSample()
            let quality = qualityEvaluator.evaluate(sample: sample, previousSample: previousSample, stage: machine.stage)
            previousSample = sample
            latestSample = sample
            lastQuality = quality
            acceptedFrameCount += quality.acceptedFrameCount
            rejectedFrameCount += quality.rejectedFrameCount
            guidance = quality.guidance
            machine.advance(with: sample, quality: quality)
            syncFromMachine()
            if machine.stage == .localAnalysis {
                await finishAnalysis(quality: quality)
            }
        } catch {
            machine.markFailed()
            guidance = error.localizedDescription
            diagnostics.record(.init(level: .error, category: "scanner", message: "Capture failed: \(error.localizedDescription)"))
            syncFromMachine()
        }
    }

    func runGuidedScan() async {
        guard !isAutoScanning else { return }
        isAutoScanning = true
        defer { isAutoScanning = false }

        if !isRunning {
            await begin()
        }

        for _ in 0..<40 {
            if Task.isCancelled || !isRunning || stage == .results || stage == .failed || stage == .permissionDenied || stage == .unsupportedDevice {
                break
            }
            await captureNextSample()
            try? await Task.sleep(nanoseconds: 220_000_000)
        }
    }

    func stop() {
        captureProvider.stop()
        isRunning = false
        isAutoScanning = false
    }

    private func finishAnalysis(quality: ScanQualityResult) async {
        isRunning = false
        captureProvider.stop()
        do {
            let measurements = measurementEngine.analyze(samples: machine.acceptedSamples, quality: quality)
            let score = try await scoringEngine.score(measurements: measurements, scanQuality: quality)
            let newReport = measurementEngine.makeReport(samples: machine.acceptedSamples, quality: quality, scoring: score)
            let session = ScanSession(
                createdAt: Date(),
                stagesCompleted: machine.completedStages,
                acceptedSamples: machine.acceptedSamples,
                report: newReport
            )
            try scanStore.save(session)
            report = newReport
            machine.markResultsReady()
            guidance = "Analysis complete."
            diagnostics.record(.init(level: .info, category: "scanner", message: "Scan completed with \(machine.acceptedSamples.count) samples"))
            syncFromMachine()
        } catch {
            machine.markFailed()
            guidance = error.localizedDescription
            diagnostics.record(.init(level: .error, category: "scanner", message: "Analysis failed: \(error.localizedDescription)"))
            syncFromMachine()
        }
    }

    private func syncFromMachine() {
        stage = machine.stage
    }
}
