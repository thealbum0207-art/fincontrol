#!/usr/bin/env python3
"""Configure release signing in Flutter generated Kotlin Gradle file."""
import os
from pathlib import Path

path = Path("android/app/build.gradle.kts")
if not path.exists():
    raise SystemExit("Gradle Kotlin file missing")
required = (
    "FINCONTROL_KEYSTORE_FILE", "FINCONTROL_STORE_PASSWORD",
    "FINCONTROL_KEY_ALIAS", "FINCONTROL_KEY_PASSWORD",
)
if any(not os.environ.get(name) for name in required):
    raise SystemExit("Release signing environment variables missing")

code = path.read_text(encoding="utf-8")
debug = 'signingConfig = signingConfigs.getByName("debug")'
marker = "    buildTypes {"
if code.count(debug) != 1 or code.count(marker) != 1:
    raise SystemExit("Unexpected Gradle template; refusing unsigned/incorrect release")
signing = r'''
    signingConfigs {
        create("fincontrolUpload") {
            storeFile = file(System.getenv("FINCONTROL_KEYSTORE_FILE")
                ?: error("FINCONTROL_KEYSTORE_FILE missing"))
            storePassword = System.getenv("FINCONTROL_STORE_PASSWORD")
                ?: error("FINCONTROL_STORE_PASSWORD missing")
            keyAlias = System.getenv("FINCONTROL_KEY_ALIAS")
                ?: error("FINCONTROL_KEY_ALIAS missing")
            keyPassword = System.getenv("FINCONTROL_KEY_PASSWORD")
                ?: error("FINCONTROL_KEY_PASSWORD missing")
        }
    }
'''
code = code.replace(marker, signing + "\n" + marker, 1)
code = code.replace(debug, 'signingConfig = signingConfigs.getByName("fincontrolUpload")', 1)
path.write_text(code, encoding="utf-8")
print("Release signing prepared from private environment variables.")
