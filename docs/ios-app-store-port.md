# Bloodstream Defender iOS App Store Port

## Recommendation

Use the Godot version as the App Store build.

The web version is useful for quick sharing, but the Godot build is the better iOS path because it already contains the richer game systems, imported assets, audio, HUD, boss flow, and mobile runtime hooks. Godot exports an Xcode project for iOS, then Xcode and App Store Connect handle signing, TestFlight, archiving, validation, and upload.

Official references:

- Godot iOS export docs: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html
- Apple upload builds docs: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/

## Repo State

- Godot project: `project.godot`
- Main scene: `scenes/main.tscn`
- Runtime script: `scripts/godot/main.gd`
- App Store source icon: `assets/ui/app-icon-option-1-face-shield.png`
- Current project icon path: `res://assets/ui/app-icon-option-1-face-shield.png`
- Apple Team ID: `Q6M3ZUXKX5`
- Bundle identifier: `com.niko.bloodstreamdefender`
- Current iOS export preset: `iOS App Store`
- Godot version checked locally: `4.7.stable.official.5b4e0cb0f`
- Xcode version checked locally: `Xcode 26.5`
- Local code-signing identities checked with `security find-identity -v -p codesigning`: `0 valid identities found`
- Latest Godot CLI export generated an iOS Xcode project in `build/ios`
- Latest Xcode compile/archive test proved the generated project can build when signing identity conflicts are bypassed
- Latest App Store `.ipa` export failed because the Apple team cannot currently create App Store provisioning profiles and no iOS Distribution certificate is installed

The project is already configured for landscape play:

```text
display/window/handheld/orientation=0
```

In Godot 4.7, `0` maps to `Landscape`.

## Work Completed For iOS

- Kept the port on Godot instead of wrapping the browser game.
- Added a mobile virtual movement joystick to the active gameplay HUD.
- Kept existing mobile fire, dash, pulse, and optional tilt controls.
- Prevented left-side movement touches from also triggering antibody fire.
- Replaced the old small project icon with a fresh ImageGen 1024 x 1024 RGB App Store icon.
- Added exact-size iPhone/iPad icon variants under `assets/ui/app-icons/` for the Godot iOS export preset.
- Added an `iOS App Store` Godot export preset using Team ID `Q6M3ZUXKX5` and bundle identifier `com.niko.bloodstreamdefender`.
- Added `build/.gdignore` and Git ignore rules so generated Xcode output is not packed back into the Godot game or committed to Git.
- Filled non-empty iOS privacy usage strings for camera, microphone, and photo library keys to avoid Xcode store-validation warnings.
- Set the release signing identity to `Apple Development` for Xcode automatic-signing compatibility; the App Store export method remains `app-store`.
- Verified the Godot project imports and boots headlessly after the changes.
- Verified the Godot iOS export completes and creates the Xcode project files.
- Verified Xcode can compile the exported project when signing is bypassed; a signed archive still requires Apple account provisioning.

## Remaining App Store Blockers

These cannot be completed without account-specific Apple access:

- Apple Developer Program membership.
- Permission on Team ID `Q6M3ZUXKX5` to create App Store provisioning profiles, or an already-created App Store provisioning profile for `com.niko.bloodstreamdefender`.
- An installed iOS Distribution signing certificate in Keychain, or Xcode access that can create/download one.
- App Store Connect app record, screenshots, age rating, privacy answers, and TestFlight review.
- Final marketing/app metadata: app name availability, subtitle, category, age rating, support URL, privacy policy URL if required, and screenshots.

The latest `xcodebuild -exportArchive` attempt reached Apple and failed with:

```text
Team does not have permission to create "iOS App Store" provisioning profiles.
No profiles for 'com.niko.bloodstreamdefender' were found.
No signing certificate "iOS Distribution" found.
```

## Godot 4.7 Export Templates

Godot 4.7 iOS export templates are required. If they are missing, the safest path is:

1. Open the project in Godot.
2. Go to `Editor > Manage Export Templates`.
3. Install the templates for Godot `4.7.stable`.

The command-line equivalent is:

```bash
curl -L --fail -o /private/tmp/Godot_v4.7-stable_export_templates.tpz \
  https://github.com/godotengine/godot/releases/download/4.7-stable/Godot_v4.7-stable_export_templates.tpz

mkdir -p "$HOME/Library/Application Support/Godot/export_templates/4.7.stable"

unzip -j /private/tmp/Godot_v4.7-stable_export_templates.tpz 'templates/*' \
  -d "$HOME/Library/Application Support/Godot/export_templates/4.7.stable"
```

The template archive is large, about 1.28 GB.

As of the latest local check, `ios.zip` exists in:

```text
$HOME/Library/Application Support/Godot/export_templates/4.7.stable
```

## Create The iOS Export Preset

In Godot:

1. Open `Project > Export`.
2. Select the `iOS App Store` preset.
3. Confirm the bundle identifier is `com.niko.bloodstreamdefender`.
4. Confirm the Apple Team ID is `Q6M3ZUXKX5`.
5. Confirm the version is `1.0` and build is `1`.
6. Confirm the icon uses `res://assets/ui/app-icon-option-1-face-shield.png`.
7. Confirm `Export Project Only` is enabled.
8. Export to `build/ios/BloodstreamDefender.zip`.

Do not commit personal signing identities, private certificates, or provisioning profiles into the repo.

With `Export Project Only` enabled, Godot writes the Xcode project into `build/ios` and does not create a final uploadable `.zip` or `.ipa`. Xcode creates the archive and App Store `.ipa` afterward.

If Godot reports a generic configuration error during export, check signing first. The local machine must have an Apple Development or Apple Distribution signing identity available in Keychain, or Xcode must be signed into the Apple Developer account and able to create/download provisioning profiles for `com.niko.bloodstreamdefender`.

## CLI Export After The Preset Exists

Once `export_presets.cfg` exists locally and the templates are installed:

```bash
mkdir -p build/ios

/Applications/Godot.app/Contents/MacOS/Godot \
  --headless \
  --path . \
  --export-release "iOS App Store" \
  build/ios/BloodstreamDefender.zip
```

That creates the generated Xcode project at:

```text
build/ios/BloodstreamDefender.xcodeproj
```

Archive from Xcode Organizer, or from the CLI:

```bash
xcodebuild \
  -project build/ios/BloodstreamDefender.xcodeproj \
  -scheme BloodstreamDefender \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath build/ios/BloodstreamDefender.xcarchive \
  -allowProvisioningUpdates \
  archive
```

Create the App Store upload package:

```bash
xcodebuild \
  -exportArchive \
  -archivePath build/ios/BloodstreamDefender.xcarchive \
  -exportOptionsPlist build/ios/BloodstreamDefender/export_options.plist \
  -exportPath build/ios/AppStoreExport \
  -allowProvisioningUpdates
```

The archive command needs Xcode to create or download a development provisioning profile. If the Apple team has no registered iOS devices, Xcode can fail there before the App Store export step.

The final command is expected to fail until the Apple account has App Store provisioning-profile permission and an iOS Distribution certificate.

## Device QA Checklist

Before App Store submission, test on at least one real iPhone:

- Landscape launch and rotation behavior.
- Start, pause, resume, restart, level complete, upgrade, and game over flows.
- Virtual joystick movement.
- Fire, dash, pulse, and locked/unlocked ability states.
- Tilt toggle and calibration.
- Audio unlock, music mute, SFX mute, background/foreground app behavior.
- No HUD overlap on small iPhone landscape screens.
- No performance drops during boss warning, boss fights, influenza replication, and heavy particle moments.
- App icon appears correctly in the home screen, Settings, TestFlight, and App Store Connect.

## Privacy And Review Notes

The current Godot game does not appear to need camera, microphone, contacts, location, Bluetooth, HealthKit, or tracking permissions. If that remains true, the App Store privacy answers should be simple: no tracking and no data collection, unless analytics, ads, cloud saves, accounts, crash reporting, or third-party SDKs are added later.

Keep the game self-contained. App Review is usually smoother when the first launch goes directly to the playable game, no external web dependencies are required, and all controls needed for iPhone play are visible and usable.
