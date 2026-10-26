#!/usr/bin/env python3
"""Preserve Room's generated WorkManager database ctor in Flutter release R8.

Run AFTER 'flutter create' and BEFORE 'flutter build appbundle --release'.
The work-runtime / old Room consumer rules can keep WorkDatabase_Impl's type
but not its reflective no-argument constructor under R8 strict/full mode.
"""
from pathlib import Path

gradle = Path("android/app/build.gradle.kts")
proguard = Path("android/app/proguard-rules.pro")
if not gradle.is_file():
    raise SystemExit("android/app/build.gradle.kts missing; run flutter create first")

rules = """# Needed for reflective RoomDatabase instantiation by WorkManager.
# R8 full mode may preserve the type while stripping the no-arg constructor.
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>();
}
-keepclassmembers class * extends androidx.room.RoomDatabase {
    public <init>();
}
"""
proguard.write_text(rules, encoding="utf-8")
code = gradle.read_text(encoding="utf-8")
if 'proguardFiles("proguard-rules.pro")' in code:
    print("Room/WorkManager R8 rules already enabled.")
else:
    marker = "    buildTypes {"
    if code.count(marker) != 1:
        raise SystemExit("Unexpected Gradle template: buildTypes marker missing or ambiguous")
    # Add the rules inside release; do not change signing or disable R8.
    release = '        release {'
    if code.count(release) != 1:
        raise SystemExit("Unexpected Gradle template: release block missing or ambiguous")
    code = code.replace(release, release + '\n            proguardFiles("proguard-rules.pro")', 1)
    gradle.write_text(code, encoding="utf-8")
    print("Installed Room/WorkManager R8 rules for release builds.")
