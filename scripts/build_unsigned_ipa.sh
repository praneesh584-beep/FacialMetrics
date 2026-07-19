#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="FaceMetric"
SCHEME_NAME="FaceMetric"
CONFIGURATION="Debug"
DERIVED_DATA_PATH="build/DerivedData"
ARTIFACT_DIR="build/artifacts"
PAYLOAD_DIR="build/Payload"
IPA_PATH="${ARTIFACT_DIR}/FaceMetric-unsigned.ipa"

mkdir -p "${ARTIFACT_DIR}"

xcodegen generate

xcodebuild \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "${SCHEME_NAME}" \
  -configuration "${CONFIGURATION}" \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

APP_PATH="$(find "${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}-iphoneos" -maxdepth 2 -type d -name "${PROJECT_NAME}.app" -print -quit)"

if [ -z "${APP_PATH}" ] || [ ! -d "${APP_PATH}" ]; then
  echo "Expected app bundle was not found under ${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}-iphoneos." >&2
  find "${DERIVED_DATA_PATH}/Build/Products" -maxdepth 4 -type d -name "*.app" -print >&2 || true
  exit 1
fi

APP_REAL="$(cd "$(dirname "${APP_PATH}")" && pwd -P)/$(basename "${APP_PATH}")"
PRODUCT_ROOT="$(cd "${DERIVED_DATA_PATH}/Build/Products/${CONFIGURATION}-iphoneos" && pwd -P)"
case "${APP_REAL}" in
  "${PRODUCT_ROOT}"/*) ;;
  *)
    echo "Refusing to package app outside expected build output: ${APP_REAL}" >&2
    exit 1
    ;;
esac

rm -rf "${PAYLOAD_DIR}" "${IPA_PATH}"
mkdir -p "${PAYLOAD_DIR}"
cp -R "${APP_REAL}" "${PAYLOAD_DIR}/"
ditto -c -k --sequesterRsrc --keepParent "${PAYLOAD_DIR}" "${IPA_PATH}"

shasum -a 256 "${IPA_PATH}" > "${IPA_PATH}.sha256"

{
  echo "commit=$(git rev-parse HEAD)"
  echo "build_date_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "xcode_version=$(xcodebuild -version | tr '\n' ' ')"
  echo "swift_version=$(swift --version | head -n 1)"
  echo "bundle_id=$(xcodebuild -showBuildSettings -project ${PROJECT_NAME}.xcodeproj -scheme ${SCHEME_NAME} | awk -F '= ' '/PRODUCT_BUNDLE_IDENTIFIER/ {print $2; exit}')"
  echo "marketing_version=$(xcodebuild -showBuildSettings -project ${PROJECT_NAME}.xcodeproj -scheme ${SCHEME_NAME} | awk -F '= ' '/MARKETING_VERSION/ {print $2; exit}')"
  echo "build_number=$(xcodebuild -showBuildSettings -project ${PROJECT_NAME}.xcodeproj -scheme ${SCHEME_NAME} | awk -F '= ' '/CURRENT_PROJECT_VERSION/ {print $2; exit}')"
} > "${ARTIFACT_DIR}/build-info.txt"

echo "Created ${IPA_PATH}"
