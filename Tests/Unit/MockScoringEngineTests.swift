import XCTest
@testable import FaceMetric

final class MockScoringEngineTests: XCTestCase {
    func testMockScoreIsDeterministicAndLabeledDemo() async throws {
        let quality = ScanQualityResult(isAcceptable: true, score: 0.9, issues: [], guidance: "Good", acceptedFrameCount: 1, rejectedFrameCount: 0)
        let measurements = MeasurementEngine().analyze(samples: [SyntheticFaceFixtures.sample()], quality: quality)
        let engine = MockScoringEngine()

        let first = try await engine.score(measurements: measurements, scanQuality: quality)
        let second = try await engine.score(measurements: measurements, scanQuality: quality)

        XCTAssertEqual(first, second)
        XCTAssertTrue(first.isDemo)
        XCTAssertFalse(first.isScientificallyValidated)
        XCTAssertFalse(first.isEnabledByDefault)
    }
}
