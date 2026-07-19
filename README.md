# FaceMetric

FaceMetric is an original, privacy-first iPhone app foundation for guided TrueDepth facial scanning, local scan diagnostics, experimental geometric measurements, and progress tracking.

The current milestone is a mock-testable SwiftUI app shell plus compile-time ARKit capture boundary. It does not reproduce Areum's algorithm, branding, assets, data, or scoring logic.

## Current Status

- Source created on Windows.
- Xcode project generation is configured through XcodeGen.
- GitHub Actions workflows are provided for macOS validation and manual unsigned IPA creation.
- Simulator and physical iPhone validation must run in GitHub Actions and on an iPhone 11 or newer TrueDepth device.
- TrueDepth hardware behavior is pending physical-device testing.

## Privacy Defaults

- No backend.
- No analytics.
- No advertising SDKs.
- No automatic upload.
- No cloud sync.
- No RGB face image storage by default.
- No model training from user scans.
- User-initiated local export only.

## Project Layout

```text
App/                  SwiftUI app, capture, analysis, storage, diagnostics
Tests/Unit/           XCTest unit tests with synthetic fixtures
docs/                 Architecture, privacy, build, testing, and limitations docs
scripts/              macOS CI helper scripts
.github/workflows/    Validation and unsigned IPA workflows
project.yml           XcodeGen project definition
```

## Build Overview

The intended free workflow is:

```text
Windows + Codex
  -> GitHub repository
  -> GitHub Actions macOS runner
  -> XcodeGen
  -> xcodebuild unsigned device build
  -> unsigned IPA artifact
  -> AltStore Classic signing/install on iPhone
```

See `docs/WINDOWS_BUILD.md` for beginner-friendly Windows-to-iPhone steps.

## Important Limitations

FaceMetric currently reports only experimental measurements and a disabled-by-default deterministic demo score. It does not provide a scientifically validated attractiveness rating, medical advice, or demographic inference.

Physical TrueDepth validation must not be marked complete until diagnostics from a real device are reviewed.
