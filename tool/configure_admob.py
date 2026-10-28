#!/usr/bin/env python3
"""Configure o AdMob no AndroidManifest gerado pelo flutter create."""
from pathlib import Path

MANIFEST = Path("android/app/src/main/AndroidManifest.xml")
APPLICATION_ID = "ca-app-pub-3964603090939340~3759405239"

if not MANIFEST.exists():
    raise SystemExit("AndroidManifest.xml ausente")
text = MANIFEST.read_text(encoding="utf-8")
if 'com.google.android.gms.ads.APPLICATION_ID' in text:
    raise SystemExit("Ja existe AdMob Application ID; confira antes de prosseguir")
tag = "<application"
pos = text.find(tag)
if pos < 0:
    raise SystemExit("Elemento application nao encontrado")
end = text.find(">", pos)
if end < 0:
    raise SystemExit("XML de application invalido")
metadata = (
    '\n        <meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"'
    f' android:value="{APPLICATION_ID}"/>'
)
text = text[:end + 1] + metadata + text[end + 1:]
# Keep the Play Console advertising ID declaration aligned with the actual
# Android 13+ manifest. This is needed even when the transitive SDK's manifest
# fails to merge the permission into a given release artifact.
AD_ID_PERMISSION = "com.google.android.gms.permission.AD_ID"
if AD_ID_PERMISSION not in text:
    text = text.replace(
        "<application",
        '<uses-permission android:name="' + AD_ID_PERMISSION + '" />\n    <application',
        1,
    )
if "android.permission.INTERNET" not in text:
    text = text.replace(
        "<application",
        '<uses-permission android:name="android.permission.INTERNET" />\n    <application',
        1,
    )
MANIFEST.write_text(text, encoding="utf-8")
print("AdMob Application ID adicionado ao AndroidManifest gerado.")
