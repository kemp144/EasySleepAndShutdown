#!/bin/bash
# Builds a local macOS .app bundle + ad-hoc .xcarchive
# For App Store submission, use the generated Xcode project and Product -> Archive.
# Usage: ./build-app.sh [--sign] [--archive]
set -e

APP_NAME="EasySleepShutdown"
BUNDLE_NAME="Easy Sleep & Shutdown"
BUNDLE_ID="com.easysleepshutdown.app"
APP_DIR="build/${BUNDLE_NAME}.app"
ARCHIVE_DIR="build/${BUNDLE_NAME}.xcarchive"

DO_SIGN=false
DO_ARCHIVE=false

# Parse arguments
for arg in "$@"; do
  [[ "$arg" == "--sign" ]] && DO_SIGN=true
  [[ "$arg" == "--archive" ]] && DO_ARCHIVE=true
done

echo "→ Building release binary..."
swift build -c release

echo "→ Creating .app bundle structure..."
rm -rf "build"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

echo "→ Copying binary..."
cp ".build/release/${APP_NAME}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"

echo "→ Copying Info.plist..."
cp "Resources/Info.plist" "${APP_DIR}/Contents/Info.plist"

echo "→ Copying app icon..."
if [ -d "Sources/EasySleepShutdown/Assets.xcassets" ]; then
  cp -r "Sources/EasySleepShutdown/Assets.xcassets" "${APP_DIR}/Contents/Resources/"
  echo "  ✓ Assets.xcassets copied"
fi

# Sign app with entitlements if requested
if [ "$DO_SIGN" = true ]; then
  echo "→ Code signing..."
  if [ -f "EasySleepShutdown.entitlements" ]; then
    codesign -s - --entitlements "EasySleepShutdown.entitlements" \
      --options runtime "${APP_DIR}" 2>/dev/null || \
    codesign -s - --entitlements "EasySleepShutdown.entitlements" "${APP_DIR}" || \
    echo "  ℹ Self-signing skipped (use Xcode for App Store signing)"
  fi
fi

# Create .xcarchive if requested
if [ "$DO_ARCHIVE" = true ]; then
  echo "→ Creating .xcarchive..."
  rm -rf "${ARCHIVE_DIR}"
  mkdir -p "${ARCHIVE_DIR}/Products/Applications"
  cp -r "${APP_DIR}" "${ARCHIVE_DIR}/Products/Applications/"

  # Create Info.plist for archive
  cat > "${ARCHIVE_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>ApplicationProperties</key>
  <dict>
    <key>ApplicationPath</key>
    <string>Applications/${BUNDLE_NAME}.app</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>SigningIdentity</key>
    <string>Apple Distribution</string>
  </dict>
</dict>
</plist>
EOF
  echo "  ✓ Archive created"
fi

echo ""
echo "✓ Done! App bundle created at: ${APP_DIR}"
[ "$DO_ARCHIVE" = true ] && echo "✓ Archive created at: ${ARCHIVE_DIR}"
echo ""
echo "To run:              open \"${APP_DIR}\""
echo "To install locally:  cp -r \"${APP_DIR}\" /Applications/"
[ "$DO_ARCHIVE" != true ] && echo "To create archive:   ./build-app.sh --sign --archive"
