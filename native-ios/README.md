# Bloodstream Defender Native iOS Rebuild

This folder contains the new native iOS/SpriteKit rebuild of Bloodstream Defender. The Godot project at the workspace root remains the reference blueprint and should not be modified for the native port unless a change is explicitly needed there.

## Maintenance status — October 1, 2026

Version **1.1 (15)** is available for internal TestFlight testing after a signed Xcode 27 device archive, distribution export and resource audit. Availability was verified October 1, 2026 at approximately 15:47 UTC. See the [TestFlight release record](../docs/testflight-1.1-build-15-2026-10-01.md), [renewed project review and release plan](../docs/maintenance-1.1-review-2026-10-01.md), and [automated resource/regression checks](scripts/README.md). Simulator checks ran on iOS 27.0; physical-device and authenticated Game Center QA remain pending. No public App Store release was performed. The original vertical-slice notes below describe the port history. Current runtime Assets contain only referenced files; source art and alternates are preserved in `DevelopmentAssets` outside the app bundle.

## Project Structure

- `BloodstreamDefenderSpriteKit.xcodeproj` - Xcode project for the native iOS app.
- `BloodstreamDefenderSpriteKit/` - UIKit wrapper and SpriteKit gameplay code.
- `BloodstreamDefenderSpriteKit/Assets/` - copied assets from the Godot project so the native app bundle is self-contained.
- `BloodstreamDefenderSpriteKit/Assets.xcassets/` - native app icon catalog for Simulator/device installs.
- `AppStoreAssets/` - App Store Connect screenshots and Game Center artwork; kept outside the runtime `Assets/` folder so they are not bundled into the shipped app.

## Vertical Slice Scope

The first slice targets `com.niko.bloodstreamdefender.spritekit` and uses a UIKit `SKView` with a SpriteKit scene for all gameplay rendering. It includes:

- Title/start screen with live text over the bloodstream background.
- Metal-backed SpriteKit rendering through `SKView`.
- Bloodstream background rebuilt from the six Godot parallax layers with mirrored tiling and independent scroll speeds.
- Player white blood cell sprite from the existing atlas.
- Touch joystick and action buttons with layered translucent glass styling, highlights, rim glow, and glyph details.
- CoreMotion tilt movement with pause-menu toggle/calibration and saved tilt preference; keyboard and joystick input remain higher priority for testing.
- Keyboard testing controls for Simulator: WASD/arrows to move, Space/Return to fire, P to pause/resume.
- Illustrated full-screen How to Play onboarding accessible from the title and pause menus.
- Game Center leaderboard hooks, saved haptic preference, audio/feedback settings, and simulator fallback messaging when Game Center cannot open.
- Godot-style mission names, level goals, level length/progress gating, difficulty scaling, and regular enemy mix.
- Basic, fast, tank, budding, and influenza enemy variants using the existing sprite sheets.
- Influenza replication behavior when live influenza virions touch.
- Ambient red blood cells with drift, depth, soft collision push, and SpriteKit motion.
- Platelet obstacles with Godot-style level-scaled target density, quick refill when below target, bump/crack feedback, dash breaking, and pulse breaking.
- Encounter warning flow that clears the vessel lane before a boss enters.
- Pox-Brick, Adenovirus, and Filovirus boss profiles using existing boss sheets, normalized padded frame cells, health, target positions, phase/shield/frame behavior, and add spawns.
- Rotavirus Gyre, Lyssavirus Lance, and Norovirus Swarm-Core boss profiles using new processed sprite sheets and unique timing, charge, and decoy mechanics.
- Antibody shooting, homing, collisions, player damage, health, and score HUD.
- Godot-style HUD progress with left-anchored fills, cleaned-up score/health/level placement, level-complete panel, pause/settings panel, restart confirmation, upgrade picker with yellow glowing pips, and run-complete summary using existing UI art with live SpriteKit text.
- A level loop with target counts, section clear tracking, survival time, total neutralizations, bosses neutralized, and adaptation summary.
- Upgrade economy and presentation for rapid antibodies, complement pulse, and chemotaxis dash with rank copy, medallions, pips, max-rank handling, and gameplay effects.
- Godot-style dash rank scaling, facing-aware no-input dash direction, swim/dash wake trails, quick update-driven complement pulse that grows from the white blood cell center as a layered sphere/rim effect, generous visual-radius hit tests, immediate regular-virus neutralization on contact, boss damage on pulse contact, and subtle screen shake on dash/pulse/damage/defeats.
- Menu/combat/danger/boss/upgrade music, bloodstream ambience, boss warning rumble, boss hit/phase/defeat, dash/pulse, level-complete, influenza/budding, pause/restart/upgrade, and core shot/hit/pop/damage sounds from existing audio.
- Persistent best-run tracking plus saved music/effects mute settings through `UserDefaults`.
- Native app icon catalog generated from the existing app-store icon artwork.
- DEBUG Simulator shortcuts: `U` opens upgrades, `N` advances to the next level, `B` fast-forwards into the boss warning path, `L` triggers level completion, and `G` opens the run-complete summary.

## Build Notes

The first performance target is the iPhone 17 Pro Simulator at 60 FPS. Build products should be kept outside source control, for example with:

```sh
xcodebuild -project native-ios/BloodstreamDefenderSpriteKit.xcodeproj -scheme BloodstreamDefenderSpriteKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/bloodstream-spritekit-derived build
```

The current smoke-test build uses `CODE_SIGNING_ALLOWED=NO` for Simulator-only verification:

```sh
xcodebuild -project native-ios/BloodstreamDefenderSpriteKit.xcodeproj -scheme BloodstreamDefenderSpriteKit -configuration Debug -sdk iphonesimulator -derivedDataPath /private/tmp/bloodstream-spritekit-derived CODE_SIGNING_ALLOWED=NO build
```

In the Codex sandbox on 2026-06-21, direct Swift typechecking passed with:

```sh
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc -typecheck -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.5.sdk -target arm64-apple-ios18.0 -module-cache-path native-ios/SwiftModuleCache -parse-as-library native-ios/BloodstreamDefenderSpriteKit/AppDelegate.swift native-ios/BloodstreamDefenderSpriteKit/SceneDelegate.swift native-ios/BloodstreamDefenderSpriteKit/GameViewController.swift native-ios/BloodstreamDefenderSpriteKit/GameScene.swift
```

Full `xcodebuild` validation in that sandbox reached Swift compilation but failed during `actool` because CoreSimulator runtimes were unavailable to the sandboxed process (`No available simulator runtimes for platform iphonesimulator`). Re-run from an unrestricted terminal/Xcode session for final Simulator launch verification.

## Next Maintenance Steps

- Complete physical-device audio, tilt, layout, and six-boss/late-run QA for the 1.1 candidate.
- Verify the new independent Game Center maxima/retries with an authenticated account, and check legacy checkpoint compatibility before submission. Host regression tests cover offline state and account-change logic without live submissions.
- Profile before deciding whether texture atlases, image resizing, or audio recompression are worthwhile.
- The signed archive and exported IPA for 1.1 (15) passed resource and signing checks before TestFlight upload. Repeat these checks for each new build, and complete beta QA before any separately authorized public release. The existing export-options file has `destination=upload` and is not for local-only verification.
