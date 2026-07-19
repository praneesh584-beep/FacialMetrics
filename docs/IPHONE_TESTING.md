# Manual iPhone TrueDepth Test Checklist

Use a physical iPhone with a front TrueDepth camera. The first target is iPhone 11.

For failures, export diagnostics from Settings -> Diagnostics and include the screen name, expected behavior, actual behavior, and screenshot if useful.

## Checklist

1. App installation: install via AltStore Classic. Expected: app appears and launches.
2. First launch: open FaceMetric. Expected: onboarding appears with privacy-first language.
3. Camera permission approval: allow camera. Expected: scanner can continue.
4. Camera permission denial: deny camera on a fresh install or Settings reset. Expected: permission-denied screen with recovery guidance.
5. Re-enable permission: enable camera in iOS Settings. Expected: app detects permission on retry.
6. TrueDepth support detection: open scanner. Expected: iPhone 11 reports supported.
7. Portrait orientation scanning: hold phone upright. Expected: guidance remains readable.
8. Normal indoor lighting: scan in normal light. Expected: stable frames accumulate.
9. Dim lighting: reduce light. Expected: quality feedback reports lower confidence or tracking loss.
10. Bright backlighting: stand with bright light behind. Expected: guidance asks for improvement or rejects unstable frames.
11. Glasses: scan with glasses. Expected: no crash; diagnostics note tracking quality.
12. Partial obstruction: cover part of face. Expected: tracking loss or obstruction guidance.
13. Face too near: move close. Expected: move farther guidance.
14. Face too far: move away. Expected: move closer guidance.
15. Fast movement: move quickly. Expected: movement rejection.
16. Left turn: follow left prompt. Expected: stage advances.
17. Right turn: follow right prompt. Expected: stage advances.
18. Up/down tilt: tilt head. Expected: excessive pitch guidance.
19. Session interruption: cover camera or interrupt AR session. Expected: graceful recovery message.
20. Background/foreground: background app and return. Expected: session pauses and restarts safely.
21. Incoming call if practical: interrupt app. Expected: no crash, diagnostics record interruption.
22. Repeated scans: run several scans. Expected: no obvious memory growth, heat issue, or crash.
23. Delete scan: delete one scan. Expected: scan disappears.
24. Export: export diagnostics or scan summary. Expected: explicit share sheet and privacy warning.
25. Free signing expiry: reinstall or refresh after expiry. Expected: app launches after refresh.
