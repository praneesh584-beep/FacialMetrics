#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 path/to/FaceMetric-unsigned.ipa" >&2
  exit 2
fi

shasum -a 256 "$1"
