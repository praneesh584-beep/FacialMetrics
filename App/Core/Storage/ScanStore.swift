import Foundation

final class ScanStore {
    private let fileManager: FileManager
    private let diagnostics: DiagnosticBuffer?
    private let rootDirectory: URL?
    private let folderName = "Scans"

    init(fileManager: FileManager = .default, rootDirectory: URL? = nil, diagnostics: DiagnosticBuffer? = nil) {
        self.fileManager = fileManager
        self.rootDirectory = rootDirectory
        self.diagnostics = diagnostics
    }

    func save(_ session: ScanSession) throws {
        let data = try JSONEncoder.facemetric.encode(session)
        let url = try fileURL(for: session.id)
        try ensureDirectory()
        try data.write(to: url, options: [.atomic, .completeFileProtection])
        diagnostics?.record(.init(level: .info, category: "storage", message: "Saved scan \(session.id.uuidString)"))
    }

    func loadAll() throws -> [ScanSession] {
        let directory = try scansDirectory()
        guard fileManager.fileExists(atPath: directory.path) else { return [] }
        return try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
            .map { try JSONDecoder.facemetric.decode(ScanSession.self, from: Data(contentsOf: $0)) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func delete(_ session: ScanSession) throws {
        let url = try fileURL(for: session.id)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
            diagnostics?.record(.init(level: .info, category: "storage", message: "Deleted scan \(session.id.uuidString)"))
        }
    }

    func deleteAll() throws {
        let directory = try scansDirectory()
        if fileManager.fileExists(atPath: directory.path) {
            try fileManager.removeItem(at: directory)
        }
        diagnostics?.record(.init(level: .warning, category: "storage", message: "Deleted all scans"))
    }

    private func ensureDirectory() throws {
        let directory = try scansDirectory()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    private func fileURL(for id: UUID) throws -> URL {
        try scansDirectory().appendingPathComponent("\(id.uuidString).json")
    }

    private func scansDirectory() throws -> URL {
        if let rootDirectory {
            return rootDirectory.appendingPathComponent(folderName, isDirectory: true)
        }
        return try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(AppConfiguration.displayName, isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)
    }
}

extension JSONEncoder {
    static var facemetric: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var facemetric: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
