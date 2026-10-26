#!/usr/bin/env python3
"""Verify AD_ID is declared in the shipped Android App Bundle.

This is a fail-closed packaging check for Google Play Advertising ID
declarations. AAB's base/manifest/AndroidManifest.xml is encoded as proto;
the permission string is included verbatim by the bundle packaging step.
"""
import sys
from pathlib import Path
from zipfile import ZipFile

AD_ID = b"com.google.android.gms.permission.AD_ID"
MANIFEST_PATH = "base/manifest/AndroidManifest.xml"

def validate(bundle: Path) -> None:
    if not bundle.is_file():
        raise SystemExit("ERROR: AAB not found")
    with ZipFile(bundle) as bundle_archive:
        if MANIFEST_PATH not in bundle_archive.namelist():
            raise SystemExit("ERROR: Android manifest not found in AAB")
        manifest = bundle_archive.read(MANIFEST_PATH)
        if AD_ID not in manifest:
            raise SystemExit(
                "ERROR: missing com.google.android.gms.permission.AD_ID in "
                "AAB Android manifest. Do not upload this version."
            )
    print("PASS: AD_ID permission is present in the packaged AAB manifest.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python3 tool/check_ad_id_aab.py path/to/app.aab")
    validate(Path(sys.argv[1]))
