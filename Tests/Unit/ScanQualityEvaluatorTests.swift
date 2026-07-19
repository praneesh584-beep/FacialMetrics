import XCTest
@testable import FaceMetric

final class ScanQualityEvaluatorTests: XCTestCase {
    private let evaluator = ScanQualityEvaluator(configuration: .initial)

    func testAcceptsNeutralSyntheticSample() {
        let result = evaluator.evaluate(sample: SyntheticFaceFixtures.sample(), previousSample: nil, stage: .centerFace)
        XCTAssertTrue(result.isAcceptable)
        XCTAssertTrue(result.issues.isEmpty)
    }

    func testRejectsMultipleFaces() {
        let sample = SyntheticFaceFixtures.sample(trackedFaceCount: 2)
        let result = evaluator.evaluate(sample: sample, previousSample: nil, stage: .centerFace)
        XCTAssertFalse(result.isAcceptable)
        XCTAssertTrue(result.issues.contains(.multipleFaces))
    }

    func testRequiresLeftTurnDuringLeftStage() {
        let sample = SyntheticFaceFixtures.sample(yaw: 0.05)
        let result = evaluator.evaluate(sample: sample, previousSample: nil, stage: .turnLeft)
        XCTAssertFalse(result.isAcceptable)
        XCTAssertTrue(result.issues.contains(.needsLeftTurn))
    }

    func testRejectsSuddenMovement() {
        let previous = SyntheticFaceFixtures.sample(translation: Vector3(x: 0, y: 0, z: -0.6))
        let current = SyntheticFaceFixtures.sample(translation: Vector3(x: 0.2, y: 0, z: -0.6))
        let result = evaluator.evaluate(sample: current, previousSample: previous, stage: .centerFace)
        XCTAssertFalse(result.isAcceptable)
        XCTAssertTrue(result.issues.contains(.suddenMovement))
    }
}
