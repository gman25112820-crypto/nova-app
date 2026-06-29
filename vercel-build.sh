#!/usr/bin/env bash
set -euo pipefail
FLUTTER_VERSION="3.41.6"
git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_VERSION" _flutter
export PATH="$PWD/_flutter/bin:$PATH"
flutter --version
flutter config --enable-web
flutter pub get
flutter build web --release -t lib/main_fab.dart
