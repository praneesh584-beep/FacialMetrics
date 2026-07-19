# Agent Instructions

FaceMetric is a privacy-first iPhone TrueDepth facial-analysis foundation. Future coding agents must preserve the product boundaries in this file.

Before editing:

- Read `PLAN.md`, `docs/ARCHITECTURE.md`, and recent Git history.
- Keep work small enough to validate.
- Check the current repository state and avoid overwriting user changes.

Required principles:

- Preserve the on-device design. Do not introduce a backend, telemetry, analytics, advertising SDKs, authentication providers, payments, subscriptions, or remote logging without explicit approval.
- Never claim scientific validity, attractiveness validity, medical value, or diagnostic value without evidence.
- Never infer protected or sensitive personal traits from a face, including race, ethnicity, religion, sexual orientation, gender identity, medical condition, disability, mental state, political beliefs, nationality, immigration status, criminality, personality, trustworthiness, or intelligence.
- Never commit real facial scans, RGB face images, private user data, credentials, provisioning profiles, signing keys, Apple credentials, GitHub tokens, or AltStore credentials.
- Use synthetic fixtures in tests.
- Update documentation when architecture, privacy behavior, measurements, CI, signing, or testing workflows change.
- Report whether a result was compiler-tested, unit-tested, simulator-tested, or physical-device-tested.
- Investigate warnings rather than hiding them.
- Avoid force pushes and destructive Git operations.
- Never expose credentials in source, logs, build artifacts, GitHub Actions output, diagnostics, screenshots, or sample data.

Verification:

- On macOS with Xcode and XcodeGen: `bash ./scripts/verify_project.sh`.
- For an unsigned device IPA on macOS CI: run the `Build Unsigned iPhone IPA` workflow.
- On Windows, syntax-check scripts where possible and rely on GitHub Actions for Apple-toolchain validation.

Status language:

- `Compiled successfully` means Xcode completed a build.
- `Unit tests passed` means XCTest completed.
- `Simulator UI tested` means the mock flow was exercised in Simulator.
- `Physical TrueDepth test pending` means no iPhone hardware result has been supplied.
- `Physical TrueDepth test passed` requires user-provided diagnostics from a real TrueDepth device.
