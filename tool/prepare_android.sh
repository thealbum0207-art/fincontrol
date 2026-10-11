#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v flutter >/dev/null 2>&1; then
  echo 'Erro: Flutter SDK não encontrado. Instale Flutter primeiro.' >&2
  exit 1
fi
if [ ! -d android ]; then
  flutter create --platforms=android --org com.app --project-name fincontrol .
fi
flutter pub get
printf '\nIdentificador esperado: com.app.fincontrol\n'
printf 'IMPORTANTE: confira o identificador, versionCode e assinatura antes de publicar.\n'
