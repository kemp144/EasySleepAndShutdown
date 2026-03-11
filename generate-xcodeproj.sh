#!/bin/bash
set -euo pipefail

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen is not installed."
  echo "Install it with: brew install xcodegen"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Generating EasySleepAndShutdown.xcodeproj from project.yml..."
xcodegen generate
echo "Done: $SCRIPT_DIR/EasySleepAndShutdown.xcodeproj"
