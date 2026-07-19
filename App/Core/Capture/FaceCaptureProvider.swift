import Foundation

protocol FaceCaptureProvider: AnyObject {
    var isSupported: Bool { get }
    func requestPermission() async -> Bool
    func start() async throws
    func stop()
    func captureStableSample() async throws -> FaceFrameSample
}

enum FaceCaptureError: LocalizedError, Equatable {
    case unsupportedDevice
    case permissionDenied
    case sessionNotRunning
    case noSampleAvailable
    case interrupted(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedDevice:
            return "Face tracking is not supported on this device."
        case .permissionDenied:
            return "Camera permission is required to scan."
        case .sessionNotRunning:
            return "The capture session is not running."
        case .noSampleAvailable:
            return "No stable face sample is available yet."
        case .interrupted(let reason):
            return "The capture session was interrupted: \(reason)"
        }
    }
}

enum CapturePermissionState: String, Codable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
}
