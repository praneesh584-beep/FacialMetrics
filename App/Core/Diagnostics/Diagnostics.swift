import Combine
import Foundation
import OSLog

enum DiagnosticLevel: String, Codable, Sendable {
    case debug
    case info
    case warning
    case error
}

struct AppDiagnosticEvent: Codable, Equatable, Identifiable, Sendable {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var level: DiagnosticLevel
    var category: String
    var message: String
}

final class DiagnosticBuffer: ObservableObject {
    @Published private(set) var events: [AppDiagnosticEvent] = []

    private let capacity: Int
    private let logger = Logger(subsystem: AppConfiguration.placeholderBundleIdentifier, category: "diagnostics")

    init(capacity: Int) {
        self.capacity = capacity
    }

    func record(_ event: AppDiagnosticEvent) {
        let redacted = AppDiagnosticEvent(
            id: event.id,
            timestamp: event.timestamp,
            level: event.level,
            category: event.category,
            message: DiagnosticRedactor.redact(event.message)
        )
        events.append(redacted)
        if events.count > capacity {
            events.removeFirst(events.count - capacity)
        }
        logger.log(level: redacted.osLogType, "\(redacted.category, privacy: .public): \(redacted.message, privacy: .public)")
    }

    func exportText() -> String {
        events.map { event in
            "[\(event.timestamp.ISO8601Format())] \(event.level.rawValue.uppercased()) \(event.category): \(event.message)"
        }.joined(separator: "\n")
    }

    func exportJSONData() throws -> Data {
        try JSONEncoder.facemetric.encode(events)
    }

    func clear() {
        events.removeAll()
        record(.init(level: .info, category: "diagnostics", message: "Diagnostics cleared"))
    }
}

private extension AppDiagnosticEvent {
    var osLogType: OSLogType {
        switch level {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}

enum DiagnosticRedactor {
    static func redact(_ input: String) -> String {
        var output = input
        let patterns = [
            #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#,
            #"(?i)(token|secret|password|credential|key)=['\"]?[^\\s,'\"]+"#,
            #"[A-Za-z]:\\(?:[^\\/:*?\"<>|\r\n]+\\)*[^\\/:*?\"<>|\r\n]*"#,
            #"/Users/[^\\s]+"#
        ]
        for pattern in patterns {
            output = output.replacingOccurrences(of: pattern, with: "[redacted]", options: .regularExpression)
        }
        return output
    }
}
