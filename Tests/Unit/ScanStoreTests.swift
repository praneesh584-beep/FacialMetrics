import XCTest
@testable import FaceMetric

final class ScanStoreTests: XCTestCase {
    func testSaveLoadDeleteAndDeleteAll() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let store = ScanStore(rootDirectory: root)
        let session = ScanSession(
            createdAt: Date(),
            stagesCompleted: [.centerFace, .results],
            acceptedSamples: [SyntheticFaceFixtures.sample()],
            report: nil
        )

        try store.save(session)
        XCTAssertEqual(try store.loadAll().count, 1)

        try store.delete(session)
        XCTAssertEqual(try store.loadAll().count, 0)

        try store.save(session)
        try store.deleteAll()
        XCTAssertEqual(try store.loadAll().count, 0)
    }
}
