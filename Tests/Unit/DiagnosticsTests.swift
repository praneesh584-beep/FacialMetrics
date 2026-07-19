import XCTest
@testable import FaceMetric

final class DiagnosticsTests: XCTestCase {
    func testRedactsEmailsSecretsAndWindowsPaths() {
        let input = #"email test@example.com token=abc123 path C:\Users\person\secret.txt"#
        let output = DiagnosticRedactor.redact(input)
        XCTAssertFalse(output.contains("test@example.com"))
        XCTAssertFalse(output.contains("abc123"))
        XCTAssertFalse(output.contains(#"C:\Users"#))
        XCTAssertTrue(output.contains("[redacted]"))
    }

    func testBufferRespectsCapacity() {
        let buffer = DiagnosticBuffer(capacity: 2)
        buffer.record(.init(level: .info, category: "test", message: "one"))
        buffer.record(.init(level: .info, category: "test", message: "two"))
        buffer.record(.init(level: .info, category: "test", message: "three"))
        XCTAssertEqual(buffer.events.count, 2)
        XCTAssertFalse(buffer.exportText().contains("one"))
    }
}
