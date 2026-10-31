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

# local_auth's Android biometric dialog requires an AppCompat launch theme
# on Android 8 and older.
styles = Path("android/app/src/main/res/values/styles.xml")
if not styles.is_file():
    raise SystemExit("Flutter Android styles.xml missing")
style_text = styles.read_text(encoding="utf-8")
if 'Theme.AppCompat.DayNight' not in style_text:
    for parent in ('@android:style/Theme.Light.NoTitleBar',
                   '@android:style/Theme.Black.NoTitleBar'):
        style_text = style_text.replace(parent, 'Theme.AppCompat.DayNight')
    styles.write_text(style_text, encoding="utf-8")
gradle = Path("android/app/build.gradle.kts")
if not gradle.is_file():
    raise SystemExit("Missing Gradle Kotlin build file")
gradle_text = gradle.read_text(encoding="utf-8")
if 'androidx.appcompat:appcompat' not in gradle_text:
    gradle_text += '\n' + (
        'dependencies {\n'
        '    implementation("androidx.appcompat:appcompat:1.7.1")\n'
        '}\n'
    )
    gradle.write_text(gradle_text, encoding="utf-8")
print("Android AppCompat biometric theme configured.")
