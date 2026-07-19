# Architecture

FaceMetric separates camera capture, scan guidance, analysis, scoring, storage, diagnostics, and UI.

## Layers

- `Features`: SwiftUI screens for onboarding, scanner, results, history, settings, and diagnostics.
- `Core/Capture`: capture-provider protocol and shared errors.
- `Core/TrueDepth`: ARKit implementation and future AVFoundation raw-depth boundary.
- `Core/Measurement`: scan quality and experimental measurement logic.
- `Core/Scoring`: replaceable scoring interface plus deterministic mock scoring for development only.
- `Core/Storage`: local JSON persistence.
- `Core/Diagnostics`: app-visible bounded diagnostics plus OSLog.
- `Core/Privacy`: redaction and export privacy helpers.
- `Models`: app-owned Codable representations, avoiding direct Codable conformance on Apple framework types.

## Capture Boundary

Views do not own ARKit or AVFoundation sessions. Scanner UI depends on:

```swift
protocol FaceCaptureProvider {
    var isSupported: Bool { get }
    func requestPermission() async -> Bool
    func start() async throws
    func stop()
    func captureStableSample() async throws -> FaceFrameSample
}
```

The mock provider drives hidden simulator workflows and unit tests. `ARKitFaceCaptureProvider` is the physical-device path and uses `ARFaceTrackingConfiguration` when available.

`FaceMeshPreview` renders accepted ARKit mesh samples locally with SceneKit. It is a visualization of captured geometry, not a remote upload, RGB face image, or validated anatomical landmark model.

## Status Boundaries

Compilation, unit tests, simulator UI testing, and physical TrueDepth testing are separate statuses. CI can prove only project generation, build, and mock/unit behavior. Real sensor behavior requires an iPhone diagnostic export.
