# Windows Build And iPhone Installation

These steps use GitHub Actions for Apple tooling and AltStore Classic for local signing and installation.

## 1. Prepare Windows

1. Install Git for Windows from the official Git site.
2. Install VS Code or use the Codex Windows interface.
3. Create or clone the FaceMetric repository.
4. Commit changes locally.
5. Push the repository to GitHub.

A public repository can use free standard GitHub-hosted runners, but the source code is visible. A private repository keeps source private but uses included GitHub Actions minutes, so macOS workflows should be run intentionally.

## 2. Run The Unsigned IPA Workflow

1. Open the GitHub repository in a browser.
2. Select the Actions tab.
3. Choose `Build Unsigned iPhone IPA`.
4. Select `Run workflow`.
5. Wait for the workflow to complete.
6. If it fails, open the failed step and copy the relevant error into a Codex task.
7. Download the `FaceMetric-unsigned-ipa` artifact ZIP.
8. Extract the ZIP on Windows.

## 3. Verify The Checksum On Windows

In PowerShell, from the extracted artifact folder:

```powershell
Get-FileHash .\FaceMetric-unsigned.ipa -Algorithm SHA256
Get-Content .\FaceMetric-unsigned.ipa.sha256
```

The hash values should match.

## 4. Install With AltStore Classic

AltStore Classic is a separate third-party tool. It is not part of Xcode or GitHub Actions.

1. Install AltServer/AltStore Classic using AltStore's official instructions.
2. Connect the iPhone with a cable.
3. Trust the computer on the iPhone when prompted.
4. Enable Developer Mode on the iPhone if iOS requires it.
5. Open AltStore on the iPhone.
6. Select the extracted unsigned IPA.
7. Let AltStore sign and install it locally.
8. Refresh or reinstall before the free Apple development profile expires, commonly after seven days.

Do not put Apple credentials in GitHub, source files, workflow logs, or issue reports.

## 5. After Installation

1. Launch FaceMetric.
2. Complete onboarding.
3. Try camera permission approval and denial cases.
4. Open Settings, then Diagnostics.
5. Export diagnostics after any scanner failure.
6. Attach diagnostics to a GitHub issue or Codex task using the physical-device test template.
