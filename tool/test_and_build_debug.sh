#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
./tool/prepare_android.sh
flutter analyze
flutter test
flutter build apk --debug
printf '\nAPK de teste: build/app/outputs/flutter-apk/app-debug.apk\n'
printf 'NÃO envie o APK debug como versão de produção.\n'
