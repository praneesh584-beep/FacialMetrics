# Privacy

FaceMetric is designed for local processing first.

## MVP Defaults

- No server.
- No automatic upload.
- No analytics.
- No advertising SDK.
- No background transfer.
- No cloud synchronization.
- No use of scans to train a model.
- No full RGB face-image storage by default.
- User-initiated export only.

## Stored Data

The MVP stores accepted synthetic or device-created scan summaries locally as JSON:

- Scan ID and date.
- Schema and algorithm versions.
- Stable mesh sample summary.
- Pose and scan-quality metrics.
- Experimental measurements.
- Diagnostic metadata needed to understand failures.

It does not collect device identifiers, advertising identifiers, contacts, precise location, account information, Apple credentials, or unrelated metadata.

## Threat Model

- Accidental face-data upload: no network client or upload workflow exists in the MVP.
- Local scan history access by another person: scans remain on device; delete actions are provided. Stronger app lock may be considered later.
- Sensitive data in logs: diagnostics redact path-like, token-like, email-like, and secret-like values and do not log full RGB images or raw meshes by default.
- Malicious dependency behavior: no third-party app dependencies are used in the MVP. XcodeGen is a build-time CI tool only.
- GitHub artifact exposure: CI uploads unsigned app artifacts, checksum, and build info only. Scan data must never be uploaded.
- Unintended iCloud backup: future storage iterations should evaluate iOS backup exclusion for scan files.
- Overly broad file sharing: exports must be explicit and explain contents before sharing.
- Misleading or harmful scores: mock score is labeled demo-only and not scientifically validated.
