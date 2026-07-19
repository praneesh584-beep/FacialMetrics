import Foundation

struct ScannerStateMachine: Equatable {
    private(set) var stage: ScanStage = .privacyExplanation
    private(set) var acceptedSamples: [FaceFrameSample] = []
    private(set) var completedStages: [ScanStage] = []
    private var stableFrameCount = 0

    let requiredStableFramesPerStage: Int

    init(requiredStableFramesPerStage: Int = 2) {
        self.requiredStableFramesPerStage = requiredStableFramesPerStage
    }

    mutating func beginSupportedFlow() {
        transition(to: .preparation)
    }

    mutating func beginScanning() {
        transition(to: .centerFace)
    }

    mutating func markPermissionDenied() {
        transition(to: .permissionDenied)
    }

    mutating func markUnsupported() {
        transition(to: .unsupportedDevice)
    }

    mutating func markFailed() {
        transition(to: .failed)
    }

    mutating func advance(with sample: FaceFrameSample, quality: ScanQualityResult) {
        guard quality.isAcceptable else {
            stableFrameCount = 0
            return
        }

        stableFrameCount += 1
        if stableFrameCount < requiredStableFramesPerStage {
            return
        }

        acceptedSamples.append(sample)
        stableFrameCount = 0

        switch stage {
        case .preparation:
            transition(to: .centerFace)
        case .centerFace:
            transition(to: .neutralExpression)
        case .neutralExpression:
            transition(to: .holdStill)
        case .holdStill:
            transition(to: .turnLeft)
        case .turnLeft:
            transition(to: .returnCenterFromLeft)
        case .returnCenterFromLeft:
            transition(to: .turnRight)
        case .turnRight:
            transition(to: .returnCenterFromRight)
        case .returnCenterFromRight:
            transition(to: .localAnalysis)
        default:
            break
        }
    }

    mutating func markResultsReady() {
        transition(to: .results)
    }

    private mutating func transition(to newStage: ScanStage) {
        if completedStages.last != stage {
            completedStages.append(stage)
        }
        stage = newStage
    }
}
