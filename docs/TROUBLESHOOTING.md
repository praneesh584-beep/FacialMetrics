# Troubleshooting

## GitHub Actions Build Fails Before XcodeGen

- Check that the runner is `macos-15`.
- Re-run the job once if Homebrew temporarily fails.
- Include the failed step output in an issue.

## XcodeGen Fails

- Confirm `project.yml` syntax.
- Run `xcodegen generate` on a Mac if available.

## Simulator Tests Fail

- Attach `facemetric-test-results` from the failed workflow.
- Include the Xcode and Swift versions printed by the workflow.

## IPA Artifact Missing

- Open the `Build unsigned IPA` step.
- Look for the app bundle search output.
- Confirm the app target name is still `FaceMetric`.

## AltStore Install Fails

- Verify the SHA-256 checksum.
- Confirm the iPhone trusts the Windows computer.
- Confirm Developer Mode is enabled if required.
- Refresh AltStore and try again.

## TrueDepth Scanner Fails

- Export diagnostics from the app.
- Include iPhone model, iOS version, app commit, camera permission status, and whether TrueDepth support was reported.
