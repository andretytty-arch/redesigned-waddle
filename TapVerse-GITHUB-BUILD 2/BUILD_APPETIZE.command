#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DERIVED="$ROOT/.build-appetize"
OUTPUT="$ROOT/TapVerse-Simulator.zip"

cd "$ROOT"
rm -rf "$DERIVED" "$OUTPUT"

xcodebuild \
  -project TapVerse.xcodeproj \
  -scheme TapVerse \
  -configuration Release \
  -sdk iphonesimulator \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  clean build

APP_PATH="$DERIVED/Build/Products/Release-iphonesimulator/TapVerse.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Ошибка: TapVerse.app не найден."
  exit 1
fi

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$OUTPUT"
echo
echo "Готово: $OUTPUT"
open -R "$OUTPUT"
