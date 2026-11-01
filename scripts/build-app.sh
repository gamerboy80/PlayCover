#!/bin/bash
set -euo pipefail

configuration="${1:-Release}"
build_number="${2:-}"
cd "$(dirname "$0")/.."

carthage update --use-xcframeworks
settings=(
  CODE_SIGN_IDENTITY=-
  CODE_SIGN_STYLE=Manual
  # Ad hoc signatures have no Team ID for hardened runtime library validation.
  PLAYCOVER_CODE_SIGN_ENTITLEMENTS=PlayCover/PlayCoverAdHoc.entitlements
  DEVELOPMENT_TEAM=
  PROVISIONING_PROFILE_SPECIFIER=
  PROVISIONING_PROFILE=
)
if [[ -n "$build_number" ]]; then
  settings+=("CURRENT_PROJECT_VERSION=$build_number")
fi
CI=1 xcodebuild -project PlayCover.xcodeproj -scheme PlayCover \
  -configuration "$configuration" -destination 'generic/platform=macOS' \
  -derivedDataPath build "${settings[@]}" build
mkdir -p output
ditto "build/Build/Products/$configuration/PlayCover.app" output/PlayCover.app
codesign --verify --deep --strict --verbose=2 output/PlayCover.app
