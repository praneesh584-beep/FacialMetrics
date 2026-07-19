import Foundation

enum AppConfiguration {
    static let displayName = "FaceMetric"
    static let placeholderBundleIdentifier = "com.example.facemetric"
    static let appVersion = "0.1.0"
    static let buildNumber = "1"
    static let captureProviderVersion = "arkit-face-v0"
    static let mockCaptureProviderVersion = "mock-face-v0"
    static let measurementAlgorithmVersion = "measurement-v0"
    static let scoringAlgorithmVersion = "mock-score-v0"
}

enum AppBranding {
    static let shortPrivacySummary = "Private by default. On-device by design."
    static let experimentalLabel = "Experimental"
}
