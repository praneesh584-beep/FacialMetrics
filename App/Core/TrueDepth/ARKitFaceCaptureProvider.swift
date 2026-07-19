#if !targetEnvironment(simulator)
import ARKit
import AVFoundation
import Foundation
import UIKit

final class ARKitFaceCaptureProvider: NSObject, FaceCaptureProvider, ARSessionDelegate {
    private let session = ARSession()
    private let diagnostics: DiagnosticBuffer
    private var latestSample: FaceFrameSample?
    private var waitingContinuation: CheckedContinuation<FaceFrameSample, Error>?
    private var isRunning = false

    var isSupported: Bool {
        ARFaceTrackingConfiguration.isSupported
    }

    init(diagnostics: DiagnosticBuffer) {
        self.diagnostics = diagnostics
        super.init()
        session.delegate = self
    }

    func requestPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }

    func start() async throws {
        guard isSupported else {
            diagnostics.record(.init(level: .error, category: "capture.arkit", message: "AR face tracking unsupported"))
            throw FaceCaptureError.unsupportedDevice
        }
        guard await requestPermission() else {
            diagnostics.record(.init(level: .warning, category: "capture.arkit", message: "Camera permission denied"))
            throw FaceCaptureError.permissionDenied
        }

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        isRunning = true
        diagnostics.record(.init(level: .info, category: "capture.arkit", message: "ARKit face session started"))
    }

    func stop() {
        session.pause()
        isRunning = false
        latestSample = nil
        waitingContinuation?.resume(throwing: FaceCaptureError.interrupted("Capture stopped"))
        waitingContinuation = nil
        diagnostics.record(.init(level: .info, category: "capture.arkit", message: "ARKit face session stopped"))
    }

    func captureStableSample() async throws -> FaceFrameSample {
        guard isRunning else { throw FaceCaptureError.sessionNotRunning }
        if let latestSample {
            return latestSample
        }
        return try await withCheckedThrowingContinuation { continuation in
            waitingContinuation = continuation
        }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        let faces = anchors.compactMap { $0 as? ARFaceAnchor }
        guard let face = faces.first else { return }
        let sample = FaceFrameSample(faceAnchor: face, trackedFaceCount: faces.count, frameTimestamp: session.currentFrame?.timestamp)
        latestSample = sample
        waitingContinuation?.resume(returning: sample)
        waitingContinuation = nil
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        diagnostics.record(.init(level: .error, category: "capture.arkit", message: "AR session failed: \(error.localizedDescription)"))
        waitingContinuation?.resume(throwing: FaceCaptureError.interrupted(error.localizedDescription))
        waitingContinuation = nil
    }

    func sessionWasInterrupted(_ session: ARSession) {
        diagnostics.record(.init(level: .warning, category: "capture.arkit", message: "AR session interrupted"))
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        diagnostics.record(.init(level: .info, category: "capture.arkit", message: "AR session interruption ended"))
    }
}

private extension FaceFrameSample {
    init(faceAnchor: ARFaceAnchor, trackedFaceCount: Int, frameTimestamp: TimeInterval?) {
        let geometry = faceAnchor.geometry
        let vertices = UnsafeBufferPointer(start: geometry.vertices, count: geometry.vertexCount)
        let triangleIndices = UnsafeBufferPointer(start: geometry.triangleIndices, count: geometry.triangleCount * 3)
        let textureCoordinates = UnsafeBufferPointer(start: geometry.textureCoordinates, count: geometry.vertexCount)
        let mesh = FaceMeshSnapshot(
            vertices: vertices.map { Vector3(x: Double($0.x), y: Double($0.y), z: Double($0.z)) },
            triangleIndices: triangleIndices.map { Int($0) },
            textureCoordinates: textureCoordinates.map { Vector2(x: Double($0.x), y: Double($0.y)) }
        )
        let transform = Matrix4x4Snapshot(faceAnchor.transform)
        let pose = PoseSnapshot(
            transform: transform,
            yawRadians: PoseMath.yaw(from: faceAnchor.transform),
            pitchRadians: PoseMath.pitch(from: faceAnchor.transform),
            rollRadians: PoseMath.roll(from: faceAnchor.transform)
        )
        self.init(
            timestamp: frameTimestamp ?? Date().timeIntervalSinceReferenceDate,
            faceTransform: transform,
            pose: pose,
            mesh: mesh,
            blendShapes: BlendShapeSnapshot(
                coefficients: faceAnchor.blendShapes.reduce(into: [String: Double]()) { result, item in
                    result[item.key.rawValue] = Double(truncating: item.value)
                }
            ),
            leftEyeTransform: Matrix4x4Snapshot(faceAnchor.leftEyeTransform),
            rightEyeTransform: Matrix4x4Snapshot(faceAnchor.rightEyeTransform),
            trackingState: faceAnchor.isTracked ? "tracked" : "notTracked",
            trackedFaceCount: trackedFaceCount,
            appVersion: AppConfiguration.appVersion,
            deviceModel: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion,
            captureProviderVersion: AppConfiguration.captureProviderVersion,
            measurementAlgorithmVersion: AppConfiguration.measurementAlgorithmVersion
        )
    }
}

enum PoseMath {
    static func yaw(from transform: simd_float4x4) -> Double {
        AngleMath.normalizedRadians(Double(atan2(transform.columns.0.z, transform.columns.2.z)))
    }

    static func pitch(from transform: simd_float4x4) -> Double {
        AngleMath.normalizedRadians(Double(asin(-transform.columns.1.z)))
    }

    static func roll(from transform: simd_float4x4) -> Double {
        AngleMath.normalizedRadians(Double(atan2(transform.columns.1.x, transform.columns.1.y)))
    }
}
#endif
