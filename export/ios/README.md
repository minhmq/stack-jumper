# iOS Export Instructions

## Prerequisites

1. Install **Godot 4.3** export templates for iOS
2. macOS with **Xcode** installed (latest version)
3. **Apple Developer Account** ($99/year)
4. Provisioning profile and certificates set up in Xcode

## Xcode Setup

1. Open **Xcode → Preferences → Accounts**
2. Add your Apple ID (Developer account)
3. Download certificates and provisioning profiles

## Export Preset Configuration

1. Open **Project → Export**
2. Add **iOS** preset
3. Configure:
   - **Bundle Identifier**: `com.yourcompany.stackjumper` (must match App ID)
   - **Version**: `1.0.0`
   - **Short Version**: `1.0.0`
   - **Display Name**: `Stack Jumper`
   - **Info.plist Additions**: 
     ```
     <key>UIRequiresFullScreen</key>
     <true/>
     <key>UISupportedInterfaceOrientations</key>
     <array>
       <string>UIInterfaceOrientationPortrait</string>
     </array>
     <key>UISupportedInterfaceOrientations~ipad</key>
     <array>
       <string>UIInterfaceOrientationPortrait</string>
     </array>
     ```
   - **Signing**: Choose your development/distribution certificate
   - **Provisioning Profile**: Select your profile

## Icons & Launch Screen

1. Project Settings → Application → Config → Icon
2. Add 1024x1024 icon source to `assets/icons/icon.png`
3. Generate all sizes using Godot's icon generator or manually:
   - 1024x1024 (App Store)
   - 180x180 (iPhone)
   - 120x120 (iPhone)
   - 152x152 (iPad)
   - 167x167 (iPad Pro)
   - etc.

## Building

### Via Godot Editor:
1. Project → Export
2. Select iOS
3. Click **Export Project**
4. Choose output directory (creates `.xcodeproj`)
5. Open in Xcode
6. Build and Archive in Xcode

### Via Command Line:

```bash
godot --headless --export-release "iOS" ./ios_export/
# Then open ios_export/StackJumper.xcodeproj in Xcode
```

## Xcode Final Steps

1. Open the exported `.xcodeproj` in Xcode
2. Select your target → **Signing & Capabilities**
3. Ensure team and provisioning profile are correct
4. Set **Deployment Target**: iOS 13.0+
5. Build → Archive
6. Distribute App → App Store Connect
7. Upload to TestFlight or App Store

## App Store Connect Submission

1. Create app record in App Store Connect
2. Upload build via Xcode or Transporter
3. Complete metadata:
   - Name: "Stack Jumper"
   - Subtitle: "Vertical jumping adventure"
   - Description: See main README.md
   - Category: Games → Arcade
   - Age Rating: 4+ (no objectionable content)
4. Add screenshots (required sizes, see main README)
5. Set privacy policy (if required)
6. Submit for review

## Testing

- Use **TestFlight** for beta testing before release
- Test on multiple iOS devices and versions
- Verify portrait-only orientation lock
- Test haptics on devices that support it

## Size Optimization

Target: **< 200MB IPA**

- Similar optimizations as Android
- Use texture compression
- Consider bitcode (though disabled by default in Godot 4.x)

