# FaceMetric Plan

## Assumptions

- The repository starts as a fresh Windows workspace.
- Xcode, XcodeGen, iOS Simulator, and `xcodebuild` are unavailable locally and must run on a GitHub-hosted macOS runner.
- The first real device target is an iPhone 11 with a front TrueDepth camera.
- Bundle identifier starts as `com.example.facemetric` and is intentionally easy to change in `project.yml`.

## Phase 0: Repository And Build Foundation

Status: implemented in this scaffold, pending CI verification.

- Create documentation, agent guardrails, source layout, tests layout, scripts, and GitHub Actions.
- Configure XcodeGen with `project.yml`.
- Add manual unsigned IPA workflow.
- Document Windows, AltStore Classic, privacy, troubleshooting, and physical testing.

## Phase 1: Mock-Testable App Foundation

Status: implemented in this scaffold, pending macOS compilation and simulator/unit validation.

- Create SwiftUI shell.
- Add onboarding, privacy, scanner, results, history, settings, and diagnostics screens.
- Add `FaceCaptureProvider` protocol.
- Add mock provider with deterministic scenarios.
- Add ARKit provider boundary for physical device builds.
- Add scanner state machine and scan-quality evaluator.
- Add local JSON scan storage.
- Add diagnostics buffer, redaction, copy, clear, and export support.
- Add placeholder experimental measurement and scoring interfaces.
- Add unit tests for state machine, quality, storage models, diagnostics redaction, and mock scoring.

## Phase 2: First CI Iteration

Status: next.

- Push to GitHub.
- Run `iOS Validate`.
- Fix XcodeGen, Swift, XCTest, availability, and warning issues found by macOS.
- Record actual Xcode and Swift versions in this file after the first successful CI run.

## Phase 3: First Unsigned IPA

Status: next after simulator validation.

- Run `Build Unsigned iPhone IPA`.
- Download artifact ZIP.
- Verify SHA-256 checksum on Windows.
- Sign and install with AltStore Classic.
- Export diagnostics after first launch and scanner attempt.

## Physical TrueDepth Milestone

Status: pending user device diagnostics.

Do not mark complete until a physical iPhone confirms:

- TrueDepth support detection.
- Camera permission prompt.
- AR face tracking start.
- Face mesh and pose updates.
- Guided flow advancement.
- Stable sample capture.
- Local save, result display, deletion, diagnostics export, and repeated-scan stability.

## Later Milestones

- AVFoundation raw-depth provider.
- Validated landmark mapping.
- Pose-normalized measurements.
- Robust symmetry analysis.
- Progress comparison with uncertainty.
- Research-grade scoring pipeline design.
- App Store/TestFlight preparation.
