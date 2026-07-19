import XCTest
@testable import FaceMetric

final class CodableRoundTripTests: XCTestCase {
    func testFaceFrameSampleRoundTrip() throws {
        let sample = SyntheticFaceFixtures.sample()
        let data = try JSONEncoder.facemetric.encode(sample)
        let decoded = try JSONDecoder.facemetric.decode(FaceFrameSample.self, from: data)
        XCTAssertEqual(decoded.mesh.vertexCount, sample.mesh.vertexCount)
        XCTAssertEqual(decoded.schemaVersion, SchemaVersion.frameSample)
        XCTAssertEqual(decoded.captureProviderVersion, AppConfiguration.mockCaptureProviderVersion)
    }

    func testScanSessionRoundTrip() throws {
        let quality = ScanQualityResult(isAcceptable: true, score: 1, issues: [], guidance: "Good", acceptedFrameCount: 1, rejectedFrameCount: 0)
        let report = MeasurementEngine().makeReport(samples: [SyntheticFaceFixtures.sample()], quality: quality, scoring: nil)
        let session = ScanSession(createdAt: Date(), stagesCompleted: [.centerFace], acceptedSamples: [SyntheticFaceFixtures.sample()], report: report)
        let data = try JSONEncoder.facemetric.encode(session)
        let decoded = try JSONDecoder.facemetric.decode(ScanSession.self, from: data)
        XCTAssertEqual(decoded.schemaVersion, SchemaVersion.scanSession)
        XCTAssertEqual(decoded.acceptedSamples.count, 1)
        XCTAssertEqual(decoded.report?.schemaVersion, SchemaVersion.analysisReport)
    }
}
