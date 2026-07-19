import Foundation

enum SchemaVersion {
    static let scanSession = 1
    static let frameSample = 1
    static let analysisReport = 1
}

enum ScanStage: String, Codable, CaseIterable, Sendable {
    case privacyExplanation
    case permission
    case unsupportedDevice
    case preparation
    case centerFace
    case neutralExpression
    case holdStill
    case turnLeft
    case returnCenterFromLeft
    case turnRight
    case returnCenterFromRight
    case localAnalysis
    case results
    case permissionDenied
    case failed

    var title: String {
        switch self {
        case .privacyExplanation: return "Privacy"
        case .permission: return "Camera Permission"
        case .unsupportedDevice: return "Unsupported Device"
        case .preparation: return "Prepare"
        case .centerFace: return "Center Face"
        case .neutralExpression: return "Neutral Expression"
        case .holdStill: return "Hold Still"
        case .turnLeft: return "Turn Slightly Left"
        case .returnCenterFromLeft: return "Return To Center"
        case .turnRight: return "Turn Slightly Right"
        case .returnCenterFromRight: return "Return To Center"
        case .localAnalysis: return "Local Analysis"
        case .results: return "Results"
        case .permissionDenied: return "Permission Needed"
        case .failed: return "Scanner Interrupted"
        }
    }
}

struct FaceMeshSnapshot: Codable, Equatable, Sendable {
    var schemaVersion: Int = SchemaVersion.frameSample
    var vertices: [Vector3]
    var triangleIndices: [Int]
    var textureCoordinates: [Vector2]

    var vertexCount: Int { vertices.count }
    var triangleCount: Int { triangleIndices.count / 3 }

    var boundingWidth: Double {
        guard let minX = vertices.map(\.x).min(), let maxX = vertices.map(\.x).max() else { return 0 }
        return maxX - minX
    }

    var boundingHeight: Double {
        guard let minY = vertices.map(\.y).min(), let maxY = vertices.map(\.y).max() else { return 0 }
        return maxY - minY
    }

    var boundingDepth: Double {
        guard let minZ = vertices.map(\.z).min(), let maxZ = vertices.map(\.z).max() else { return 0 }
        return maxZ - minZ
    }
}

struct PoseSnapshot: Codable, Equatable, Sendable {
    var transform: Matrix4x4Snapshot
    var yawRadians: Double
    var pitchRadians: Double
    var rollRadians: Double

    static let neutral = PoseSnapshot(
        transform: .identity,
        yawRadians: 0,
        pitchRadians: 0,
        rollRadians: 0
    )
}

struct BlendShapeSnapshot: Codable, Equatable, Sendable {
    var coefficients: [String: Double]

    func value(_ key: String) -> Double {
        coefficients[key] ?? 0
    }
}

struct FaceFrameSample: Codable, Equatable, Identifiable, Sendable {
    var id: UUID = UUID()
    var schemaVersion: Int = SchemaVersion.frameSample
    var timestamp: TimeInterval
    var faceTransform: Matrix4x4Snapshot
    var pose: PoseSnapshot
    var mesh: FaceMeshSnapshot
    var blendShapes: BlendShapeSnapshot
    var leftEyeTransform: Matrix4x4Snapshot?
    var rightEyeTransform: Matrix4x4Snapshot?
    var trackingState: String
    var trackedFaceCount: Int
    var appVersion: String
    var deviceModel: String
    var osVersion: String
    var captureProviderVersion: String
    var measurementAlgorithmVersion: String
}

enum QualityIssue: String, Codable, CaseIterable, Hashable, Sendable {
    case noFace
    case multipleFaces
    case offCenter
    case tooClose
    case tooFar
    case excessiveYaw
    case excessivePitch
    case excessiveRoll
    case suddenMovement
    case unstableTracking
    case expressionNotNeutral
    case eyesClosed
    case meshOutlier
    case sessionInterrupted
    case needsLeftTurn
    case needsRightTurn
    case needsCenterPose
}

struct ScanQualityResult: Codable, Equatable, Sendable {
    var schemaVersion: Int = 1
    var isAcceptable: Bool
    var score: Double
    var issues: [QualityIssue]
    var guidance: String
    var acceptedFrameCount: Int
    var rejectedFrameCount: Int
}

enum MeasurementConfidence: String, Codable, Sendable {
    case low
    case medium
    case high
}

struct MeasurementDefinition: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var name: String
    var formula: String
    var unit: String
    var limitations: String
    var algorithmVersion: String
    var physicallyValidated: Bool
}

struct MeasurementValue: Codable, Equatable, Identifiable, Sendable {
    var id: String
    var definition: MeasurementDefinition
    var value: Double
    var confidence: MeasurementConfidence
}

struct MeasurementResult: Codable, Equatable, Sendable {
    var schemaVersion: Int = 1
    var algorithmVersion: String
    var values: [MeasurementValue]
}

struct ScoringResult: Codable, Equatable, Sendable {
    var schemaVersion: Int = 1
    var algorithmVersion: String
    var label: String
    var value: Double?
    var isDemo: Bool
    var isScientificallyValidated: Bool
    var isEnabledByDefault: Bool
    var explanation: String
}

struct AnalysisReport: Codable, Equatable, Identifiable, Sendable {
    var id: UUID = UUID()
    var schemaVersion: Int = SchemaVersion.analysisReport
    var createdAt: Date
    var quality: ScanQualityResult
    var measurements: MeasurementResult
    var scoring: ScoringResult?
    var sampleCount: Int
    var algorithmVersion: String
    var limitations: [String]
}

struct ScanSession: Codable, Equatable, Identifiable, Sendable {
    var id: UUID = UUID()
    var schemaVersion: Int = SchemaVersion.scanSession
    var createdAt: Date
    var stagesCompleted: [ScanStage]
    var acceptedSamples: [FaceFrameSample]
    var report: AnalysisReport?
}
