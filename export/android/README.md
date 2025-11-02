# Android Export Instructions

## Prerequisites

1. Install **Godot 4.3** export templates for Android
2. Download Android SDK and ensure `adb` is in your PATH
3. Generate a signing keystore (required for release builds)

## Keystore Setup

### Generate a new keystore:

```bash
keytool -genkeypair -v -keystore stack-jumper-release.keystore -alias stack-jumper -keyalg RSA -keysize 2048 -validity 10000
```

Store the keystore securely and note:
- **Keystore password** (you'll enter this)
- **Key alias**: `stack-jumper`
- **Key password** (can be same as keystore)

## Export Preset Configuration

1. Open **Project → Export**
2. Add **Android App Bundle (AAB)** preset
3. Configure:
   - **Package**: `com.yourcompany.stackjumper` (change to your domain)
   - **Version**: `1` (version code)
   - **Version Name**: `1.0.0`
   - **Min SDK**: `24` (Android 7.0)
   - **Target SDK**: `34` (latest)
   - **Architectures**: `arm64-v8a`, `armeabi-v7a`
   - **Keystore**: Point to your `.keystore` file
   - **Keystore Password**: Enter password
   - **Key Alias**: `stack-jumper`
   - **Key Password**: Enter key password

## Permissions

The project uses minimal permissions:
- **VIBRATE** (for haptics)
- **INTERNET** (optional, only if using share features)

No tracking or analytics SDKs are included.

## Building

### Via Godot Editor:
1. Project → Export
2. Select Android App Bundle
3. Click **Export Project**
4. Save as `stack-jumper-release.aab`

### Via Command Line (Headless):

```bash
godot --headless --export-release "Android App Bundle" stack-jumper-release.aab
```

## Testing

Install on device:
```bash
adb install -r stack-jumper-release.apk  # For APK
# AAB must be uploaded to Play Console for testing
```

## Google Play Store Submission

1. Create app listing in Google Play Console
2. Upload AAB file
3. Complete store listing:
   - App name: "Stack Jumper"
   - Short description: "Jump from platform to platform in this addictive vertical climber!"
   - Long description: See README.md
   - Category: Games → Arcade
   - Content rating: PEGI 3 / Everyone
4. Add screenshots (5 portrait images, see screenshot checklist in main README)
5. Set privacy policy URL (if required)
6. Submit for review

## Size Optimization

Target: **< 50MB AAB**

- All assets are programmatically generated or minimal PNGs
- No large textures or audio files by default
- Use Godot's texture compression (Project Settings → Rendering → Textures)

