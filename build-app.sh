#!/bin/bash
# Builds a proper macOS .app bundle from the Swift package.
# Usage: ./build-app.sh
set -e

APP_NAME="EasySleepShutdown"
BUNDLE_NAME="Easy Sleep & Shutdown"
APP_DIR="build/${BUNDLE_NAME}.app"

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

echo ""
echo "✓ Done! App bundle created at: ${APP_DIR}"
echo ""
echo "To run:  open \"${APP_DIR}\""
echo "To install: cp -r \"${APP_DIR}\" /Applications/"
