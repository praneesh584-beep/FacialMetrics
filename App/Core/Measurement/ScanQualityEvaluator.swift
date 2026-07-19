import Foundation

struct ScanQualityConfiguration: Codable, Equatable, Sendable {
    var version: String
    var minimumMeshWidth: Double
    var maximumMeshWidth: Double
    var maximumCenterOffset: Double
    var maximumCenterYawRadians: Double
    var maximumPitchRadians: Double
    var maximumRollRadians: Double
    var minimumTurnYawRadians: Double
    var maximumMovementMeters: Double
    var maximumExpressionCoefficient: Double
    var maximumEyeBlinkCoefficient: Double

    static let initial = ScanQualityConfiguration(
        version: "quality-thresholds-v0",
        minimumMeshWidth: 0.10,
        maximumMeshWidth: 0.28,
        maximumCenterOffset: 0.05,
        maximumCenterYawRadians: 0.20,
        maximumPitchRadians: 0.25,
        maximumRollRadians: 0.25,
        minimumTurnYawRadians: 0.22,
        maximumMovementMeters: 0.08,
        maximumExpressionCoefficient: 0.25,
        maximumEyeBlinkCoefficient: 0.55
    )
}

struct ScanQualityEvaluator {
    let configuration: ScanQualityConfiguration

    func evaluate(sample: FaceFrameSample, previousSample: FaceFrameSample?, stage: ScanStage) -> ScanQualityResult {
        var issues: [QualityIssue] = []

        if sample.trackedFaceCount == 0 { issues.append(.noFace) }
        if sample.trackedFaceCount > 1 { issues.append(.multipleFaces) }
        if abs(sample.pose.transform.translation.x) > configuration.maximumCenterOffset { issues.append(.offCenter) }
        if sample.mesh.boundingWidth > configuration.maximumMeshWidth { issues.append(.tooClose) }
        if sample.mesh.boundingWidth < configuration.minimumMeshWidth { issues.append(.tooFar) }
        if abs(sample.pose.pitchRadians) > configuration.maximumPitchRadians { issues.append(.excessivePitch) }
        if abs(sample.pose.rollRadians) > configuration.maximumRollRadians { issues.append(.excessiveRoll) }
        if sample.trackingState.lowercased().contains("not") { issues.append(.unstableTracking) }

        if requiresCenterPose(stage), abs(sample.pose.yawRadians) > configuration.maximumCenterYawRadians {
            issues.append(.excessiveYaw)
        }
        if stage == .turnLeft, sample.pose.yawRadians < configuration.minimumTurnYawRadians {
            issues.append(.needsLeftTurn)
        }
        if stage == .turnRight, sample.pose.yawRadians > -configuration.minimumTurnYawRadians {
            issues.append(.needsRightTurn)
        }

        if let previousSample {
            let movement = sample.pose.transform.translation.distance(to: previousSample.pose.transform.translation)
            if movement > configuration.maximumMovementMeters {
                issues.append(.suddenMovement)
            }
        }

        let expressionKeys = ["jawOpen", "mouthSmileLeft", "mouthSmileRight", "browInnerUp", "mouthFrownLeft", "mouthFrownRight"]
        if expressionKeys.map({ sample.blendShapes.value($0) }).contains(where: { $0 > configuration.maximumExpressionCoefficient }) {
            issues.append(.expressionNotNeutral)
        }
        if sample.blendShapes.value("eyeBlinkLeft") > configuration.maximumEyeBlinkCoefficient ||
            sample.blendShapes.value("eyeBlinkRight") > configuration.maximumEyeBlinkCoefficient {
            issues.append(.eyesClosed)
        }

        let score = max(0, 1 - (Double(Set(issues).count) * 0.16))
        return ScanQualityResult(
            isAcceptable: issues.isEmpty,
            score: score,
            issues: issues,
            guidance: guidance(for: issues, stage: stage),
            acceptedFrameCount: issues.isEmpty ? 1 : 0,
            rejectedFrameCount: issues.isEmpty ? 0 : 1
        )
    }

    private func requiresCenterPose(_ stage: ScanStage) -> Bool {
        switch stage {
        case .centerFace, .neutralExpression, .holdStill, .returnCenterFromLeft, .returnCenterFromRight:
            return true
        default:
            return false
        }
    }

    private func guidance(for issues: [QualityIssue], stage: ScanStage) -> String {
        guard let first = issues.first else {
            switch stage {
            case .turnLeft: return "Good. Keep the slight left turn steady."
            case .turnRight: return "Good. Keep the slight right turn steady."
            case .returnCenterFromLeft, .returnCenterFromRight: return "Good. Return to a centered position."
            default: return "Good. Hold steady."
            }
        }

        switch first {
        case .noFace: return "Center your face in view."
        case .multipleFaces: return "Only one face should be visible."
        case .offCenter: return "Center your face."
        case .tooClose: return "Move a little farther away."
        case .tooFar: return "Move a little closer."
        case .excessiveYaw: return "Look straight ahead."
        case .excessivePitch: return "Keep your head level."
        case .excessiveRoll: return "Keep your head upright."
        case .suddenMovement: return "Move more slowly."
        case .unstableTracking: return "Tracking was unstable. Hold steady."
        case .expressionNotNeutral: return "Relax your expression."
        case .eyesClosed: return "Keep your eyes gently open."
        case .meshOutlier: return "More stable frames are needed."
        case .sessionInterrupted: return "The camera session was interrupted."
        case .needsLeftTurn: return "Turn slightly left."
        case .needsRightTurn: return "Turn slightly right."
        case .needsCenterPose: return "Return to center."
        }
    }
}
