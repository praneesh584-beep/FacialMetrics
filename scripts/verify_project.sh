#!/usr/bin/env bash
set -euo pipefail

xcodegen generate
xcodebuild -version
swift --version
xcodebuild -list -project FaceMetric.xcodeproj

SIMULATOR_NAME="$(xcrun simctl list devices available | awk -F '[()]' '/iPhone/ && /Shutdown|Booted/ { gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1; exit }')"
if [ -z "${SIMULATOR_NAME}" ]; then
  echo "No available iPhone simulator found." >&2
  exit 1
fi

xcodebuild \
  -project FaceMetric.xcodeproj \
  -scheme FaceMetric \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=${SIMULATOR_NAME}" \
  CODE_SIGNING_ALLOWED=NO \
  build test
