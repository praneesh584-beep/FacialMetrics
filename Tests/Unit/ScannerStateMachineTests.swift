import XCTest
@testable import FaceMetric

final class ScannerStateMachineTests: XCTestCase {
    func testGuidedScanTransitionsToAnalysisAfterStableSamples() {
        var machine = ScannerStateMachine(requiredStableFramesPerStage: 1)
        machine.beginSupportedFlow()
        machine.beginScanning()

        let quality = ScanQualityResult(isAcceptable: true, score: 1, issues: [], guidance: "Good", acceptedFrameCount: 1, rejectedFrameCount: 0)
        for sample in SyntheticFaceFixtures.samples(for: .successfulGuidedScan) {
            machine.advance(with: sample, quality: quality)
            if machine.stage == .localAnalysis {
                break
            }
        }

        XCTAssertEqual(machine.stage, .localAnalysis)
        XCTAssertGreaterThanOrEqual(machine.acceptedSamples.count, 7)
    }

    func testRejectedFrameDoesNotAdvance() {
        var machine = ScannerStateMachine(requiredStableFramesPerStage: 1)
        machine.beginSupportedFlow()
        machine.beginScanning()
        let rejected = ScanQualityResult(isAcceptable: false, score: 0, issues: [.tooFar], guidance: "Move closer", acceptedFrameCount: 0, rejectedFrameCount: 1)
        machine.advance(with: SyntheticFaceFixtures.sample(), quality: rejected)
        XCTAssertEqual(machine.stage, .centerFace)
        XCTAssertTrue(machine.acceptedSamples.isEmpty)
    }
}
