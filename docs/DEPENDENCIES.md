# Dependencies

## App Runtime

No third-party runtime dependencies are used in the MVP.

## Build Tooling

- XcodeGen, installed in GitHub Actions with Homebrew.
- Purpose: generate `FaceMetric.xcodeproj` from checked-in `project.yml`.
- Privacy/security review: build-time only; not included in the app; no scan data is available in CI.
- Version: `project.yml` requires XcodeGen 2.42.0 or later. The exact version used by CI is printed in workflow logs.
