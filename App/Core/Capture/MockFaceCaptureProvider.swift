import Foundation

enum MockCaptureScenario: String, Codable, CaseIterable, Sendable {
    case supportedIdle
    case unsupportedDevice
    case permissionDenied
    case faceNotFound
    case multipleFaces
    case tooClose
    case tooFar
    case excessiveYaw
    case excessivePitch
    case excessiveRoll
    case movement
    case trackingInterruption
    case successfulFrontalScan
    case successfulGuidedScan
    case captureFailure
}

final class MockFaceCaptureProvider: FaceCaptureProvider {
    private let scenario: MockCaptureScenario
    private let diagnostics: DiagnosticBuffer?
    private var samples: [FaceFrameSample]
    private var isRunning = false
    private var nextIndex = 0

    var isSupported: Bool {
        scenario != .unsupportedDevice
    }

    init(scenario: MockCaptureScenario, diagnostics: DiagnosticBuffer? = nil) {
        self.scenario = scenario
        self.diagnostics = diagnostics
        self.samples = SyntheticFaceFixtures.samples(for: scenario)
    }

    func requestPermission() async -> Bool {
        let granted = scenario != .permissionDenied
        diagnostics?.record(.init(level: granted ? .info : .warning, category: "capture.mock", message: "Mock camera permission \(granted ? "granted" : "denied")"))
        return granted
    }

    func start() async throws {
        guard isSupported else { throw FaceCaptureError.unsupportedDevice }
        guard scenario != .permissionDenied else { throw FaceCaptureError.permissionDenied }
        guard scenario != .trackingInterruption else { throw FaceCaptureError.interrupted("Mock interruption") }
        isRunning = true
        diagnostics?.record(.init(level: .info, category: "capture.mock", message: "Mock capture started with scenario \(scenario.rawValue)"))
    }

    func stop() {
        isRunning = false
        diagnostics?.record(.init(level: .info, category: "capture.mock", message: "Mock capture stopped"))
    }

    func captureStableSample() async throws -> FaceFrameSample {
        guard isRunning else { throw FaceCaptureError.sessionNotRunning }
        guard scenario != .captureFailure else { throw FaceCaptureError.noSampleAvailable }
        guard !samples.isEmpty else { throw FaceCaptureError.noSampleAvailable }
        let sample = samples[min(nextIndex, samples.count - 1)]
        nextIndex += 1
        return sample
    }
}

enum SyntheticFaceFixtures {
    static func samples(for scenario: MockCaptureScenario) -> [FaceFrameSample] {
        switch scenario {
        case .faceNotFound:
            return [sample(trackedFaceCount: 0, trackingState: "notAvailable")]
        case .multipleFaces:
            return [sample(trackedFaceCount: 2)]
        case .tooClose:
            return [sample(scale: 1.9)]
        case .tooFar:
            return [sample(scale: 0.45)]
        case .excessiveYaw:
            return [sample(yaw: 0.7)]
        case .excessivePitch:
            return [sample(pitch: 0.5)]
        case .excessiveRoll:
            return [sample(roll: 0.5)]
        case .movement:
            return [
                sample(translation: Vector3(x: 0, y: 0, z: -0.55)),
                sample(translation: Vector3(x: 0.2, y: 0, z: -0.55))
            ]
        case .successfulFrontalScan:
            return Array(repeating: sample(), count: 6)
        case .successfulGuidedScan:
            return [
                sample(),
                sample(),
                sample(),
                sample(),
                sample(),
                sample(),
                sample(yaw: 0.28),
                sample(yaw: 0.31),
                sample(yaw: 0.03),
                sample(yaw: 0.01),
                sample(yaw: -0.28),
                sample(yaw: -0.32),
                sample(yaw: 0.02),
                sample(yaw: 0.0),
                sample(yaw: 0.0),
                sample(yaw: 0.0)
            ]
        default:
            return [sample()]
        }
    }

    static func sample(
        yaw: Double = 0,
        pitch: Double = 0,
        roll: Double = 0,
        scale: Double = 1,
        trackedFaceCount: Int = 1,
        trackingState: String = "normal",
        translation: Vector3 = Vector3(x: 0, y: 0, z: -0.6)
    ) -> FaceFrameSample {
        let halfWidth = 0.08 * scale
        let halfHeight = 0.11 * scale
        let vertices = [
            Vector3(x: -halfWidth, y: -halfHeight, z: 0),
            Vector3(x: halfWidth, y: -halfHeight, z: 0),
            Vector3(x: -halfWidth, y: halfHeight, z: 0),
            Vector3(x: halfWidth, y: halfHeight, z: 0),
            Vector3(x: 0, y: 0, z: 0.025)
        ]
        let transform = Matrix4x4Snapshot(values: [
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            translation.x, translation.y, translation.z, 1
        ])
        let pose = PoseSnapshot(transform: transform, yawRadians: yaw, pitchRadians: pitch, rollRadians: roll)
        return FaceFrameSample(
            timestamp: Date().timeIntervalSinceReferenceDate,
            faceTransform: transform,
            pose: pose,
            mesh: FaceMeshSnapshot(
                vertices: vertices,
                triangleIndices: [0, 1, 2, 1, 3, 2, 0, 2, 4, 1, 4, 3],
                textureCoordinates: []
            ),
            blendShapes: BlendShapeSnapshot(coefficients: [
                "jawOpen": 0.02,
                "mouthSmileLeft": 0.01,
                "mouthSmileRight": 0.01,
                "eyeBlinkLeft": 0.0,
                "eyeBlinkRight": 0.0
            ]),
            leftEyeTransform: nil,
            rightEyeTransform: nil,
            trackingState: trackingState,
            trackedFaceCount: trackedFaceCount,
            appVersion: AppConfiguration.appVersion,
            deviceModel: "Synthetic iPhone",
            osVersion: "Synthetic iOS",
            captureProviderVersion: AppConfiguration.mockCaptureProviderVersion,
            measurementAlgorithmVersion: AppConfiguration.measurementAlgorithmVersion
        )
    }
}
