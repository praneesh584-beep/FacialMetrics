import XCTest
@testable import FaceMetric

final class GeometryTests: XCTestCase {
    func testAngleNormalizationWrapsIntoPiRange() {
        XCTAssertEqual(AngleMath.normalizedRadians(Double.pi * 3), Double.pi, accuracy: 0.0001)
        XCTAssertEqual(AngleMath.normalizedRadians(Double.pi * -3), -Double.pi, accuracy: 0.0001)
    }

    func testVectorDistance() {
        let a = Vector3(x: 0, y: 0, z: 0)
        let b = Vector3(x: 3, y: 4, z: 0)
        XCTAssertEqual(a.distance(to: b), 5, accuracy: 0.0001)
    }

    func testMedianAndTrimmedMean() {
        XCTAssertEqual(RobustStats.median([5, 1, 3]), 3)
        XCTAssertEqual(RobustStats.median([4, 2, 10, 8]), 6)
        XCTAssertEqual(RobustStats.trimmedMean([1, 2, 3, 100], trimFraction: 0.25), 2.5)
    }
}
