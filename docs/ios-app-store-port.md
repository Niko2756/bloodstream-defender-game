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
- App Store source icon: `assets/ui/app-store-icon-1024.png`
- Current project icon path: `res://assets/ui/app-store-icon-1024.png`
- Godot version checked locally: `4.7.stable.official.5b4e0cb0f`
- Xcode version checked locally: `Xcode 26.5`

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
- Verified the Godot project imports and boots headlessly after the changes.

## Remaining App Store Blockers

These cannot be completed without account-specific choices:

- Apple Developer Program membership.
- Apple Team ID.
- Final bundle identifier, for example `com.niko.bloodstreamdefender`.
- Signing certificate and provisioning profile.
- App Store Connect app record, screenshots, age rating, privacy answers, and TestFlight review.
- Godot 4.7 export templates. The local folder exists, but it was empty when checked.

## Install Godot 4.7 Export Templates

In Godot, the safest path is:

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

## Create The iOS Export Preset

In Godot:

1. Open `Project > Export`.
2. Add an `iOS` preset named `iOS App Store`.
3. Set the bundle identifier, for example `com.niko.bloodstreamdefender`.
4. Set the Apple Team ID from the Apple Developer account.
5. Use release signing for App Store/TestFlight builds.
6. Confirm the icon uses `res://assets/ui/app-store-icon-1024.png`.
7. Export to `build/ios/BloodstreamDefender.zip`.

Do not commit personal signing identities, private certificates, or provisioning profiles into the repo.

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

Then unzip the export, open the generated Xcode project, select the correct team/signing settings, archive, validate, and upload through Xcode Organizer.

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
