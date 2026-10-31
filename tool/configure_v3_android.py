#!/usr/bin/env python3
"""Configure Android biometrics for a generated Flutter Android project.

Run only after 'flutter create --platforms=android --org com.app
--project-name fincontrol .' on GitHub Actions.
"""
from pathlib import Path

activity = Path("android/app/src/main/kotlin/com/app/fincontrol/MainActivity.kt")
if not activity.is_file():
    raise SystemExit(f"Android MainActivity missing: {activity}")
source = activity.read_text(encoding="utf-8")
if "FlutterFragmentActivity" not in source:
    if source.count("FlutterActivity") != 2:
        raise SystemExit("Unexpected Android activity; won't patch")
    source = source.replace("FlutterActivity", "FlutterFragmentActivity")
    activity.write_text(source, encoding="utf-8")

manifest = Path("android/app/src/main/AndroidManifest.xml")
text = manifest.read_text(encoding="utf-8")
if "android.permission.USE_BIOMETRIC" not in text:
    marker = "<application"
    if text.count(marker) != 1:
        raise SystemExit("Unexpected AndroidManifest")
    text = text.replace(marker,
        '<uses-permission android:name="android.permission.USE_BIOMETRIC" />\n    ' + marker, 1)
    manifest.write_text(text, encoding="utf-8")
print("FinControl 3: biometric activity and permission configured; no AdMob.")
