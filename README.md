# Bloodstream Defender for iOS

Bloodstream Defender is a native iOS/SpriteKit arcade game about piloting a white blood cell through a stylized bloodstream. You dodge red blood cells and platelet clots, neutralize viruses with Y-shaped antibodies, survive escalating vessel sections, and adapt between missions with immune-system upgrades.

This branch is focused on the native iOS rebuild. The older Godot project in the repository is kept as the reference blueprint, but this README documents the SpriteKit app only.

## Current Status

- Playable native SpriteKit rebuild for iPhone.
- Active Xcode project: `native-ios/BloodstreamDefenderSpriteKit.xcodeproj`.
- Bundle identifier: `com.niko.bloodstreamdefender.spritekit`.
- Primary simulator target: iPhone 17 Pro.
- Deployment target: iOS 18.0.
- App version: `0.1`.
- Rendering stack: UIKit `SKView` plus SpriteKit scene.
- Current polish focus: HUD spacing, mission progress frame, ability button layering, and high-level performance under dense enemy/projectile load.

## Screenshots

Captured from the native iOS build running on the iPhone 17 Pro simulator.

| Title | Gameplay |
| --- | --- |
| <img src="docs/screenshots/title-screen.png" alt="Bloodstream Defender title screen" width="420"> | <img src="docs/screenshots/gameplay-hud.png" alt="Bloodstream Defender gameplay HUD" width="420"> |

| Upgrade Paths | Pause Settings |
| --- | --- |
| <img src="docs/screenshots/upgrade-tree.png" alt="Choose an upgrade path screen" width="420"> | <img src="docs/screenshots/pause-menu.png" alt="Pause settings screen" width="420"> |

| Run Summary |
| --- |
| <img src="docs/screenshots/game-over-summary.png" alt="Immune run complete summary screen" width="420"> |

## Features

- Full-screen landscape SpriteKit gameplay.
- Layered parallax bloodstream background rebuilt from the reference project assets.
- White blood cell player with touch joystick, touch fire, dash, pulse, and optional tilt movement.
- Antibody projectiles with homing, rapid-fire upgrades, paired shots, stronger hits, and spread behavior.
- Regular enemy mix including basic viruses, fast variants, tank variants, budding viruses, and influenza replication.
- Platelet obstacles with collision damage, crack feedback, dash breaking, and pulse breaking.
- Boss encounters for Pox-Brick, Adenovirus, and Filovirus profiles.
- Level progression with mission names, target counts, section clear tracking, score, health, and best-run persistence.
- Upgrade branches for Rapid Antibody Factory, Complement Pulse, and Chemotaxis Dash.
- Pause/settings flow with music, effects, tilt toggle, calibration, and restart confirmation.
- Menu, combat, danger, boss, upgrade, ambience, hit, dash, pulse, pause, and completion audio.
- Performance work for busy higher levels, including projectile pooling, spark pooling, effect budgeting, and offscreen spawn fixes.

## Controls

### iPhone

| Action | Input |
| --- | --- |
| Move | Touch joystick or optional tilt controls |
| Fire antibodies | Fire touch region/button |
| Chemotaxis Dash | Dash button after unlocking the upgrade |
| Complement Pulse | Pulse button after unlocking the upgrade |
| Pause/settings | Pause button |

### Simulator Keyboard

| Action | Input |
| --- | --- |
| Move | `WASD` or arrow keys |
| Fire antibodies | `Space` |
| Chemotaxis Dash | `Shift` after unlocking the upgrade |
| Complement Pulse | `Q`, `E`, or `Return` after unlocking the upgrade |
| Pause/resume | `P` |
| Restart from pause/summary/upgrade/complete screens | `R` |

Debug builds also include shortcut keys for faster testing: `U` opens upgrades, `N` advances to the next level, `B` jumps toward a boss warning, `L` completes the current level, and `G` opens the run-complete summary.

## Build And Run

### Requirements

- macOS with Xcode installed.
- iOS Simulator runtime with iPhone 17 Pro available.
- Git.

### Xcode

1. Open `native-ios/BloodstreamDefenderSpriteKit.xcodeproj`.
2. Select the `BloodstreamDefenderSpriteKit` scheme.
3. Select an iPhone simulator, preferably iPhone 17 Pro.
4. Build and run.

### Command Line

Build for the iPhone 17 Pro simulator:

```sh
xcodebuild -project native-ios/BloodstreamDefenderSpriteKit.xcodeproj -scheme BloodstreamDefenderSpriteKit -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -derivedDataPath /private/tmp/bds-spritekit-deriveddata build
```

Install and launch on the booted simulator:

```sh
xcrun simctl install booted /private/tmp/bds-spritekit-deriveddata/Build/Products/Debug-iphonesimulator/BloodstreamDefenderSpriteKit.app
xcrun simctl terminate booted com.niko.bloodstreamdefender.spritekit
xcrun simctl launch booted com.niko.bloodstreamdefender.spritekit
```

For a Simulator-only smoke build without signing:

```sh
xcodebuild -project native-ios/BloodstreamDefenderSpriteKit.xcodeproj -scheme BloodstreamDefenderSpriteKit -configuration Debug -sdk iphonesimulator -derivedDataPath /private/tmp/bds-spritekit-deriveddata CODE_SIGNING_ALLOWED=NO build
```

## Project Layout

```text
native-ios/
├── BloodstreamDefenderSpriteKit.xcodeproj   # Xcode project
├── BloodstreamDefenderSpriteKit/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── GameViewController.swift             # UIKit/SpriteKit host view
│   ├── GameScene.swift                      # Gameplay, HUD, upgrades, audio, and level flow
│   ├── Info.plist
│   ├── Assets.xcassets/                     # Native app icon catalog
│   └── Assets/
│       ├── audio/                           # Runtime music and effects
│       ├── backgrounds/parallax/            # Bloodstream background layers
│       ├── sprites/                         # Player, enemies, bosses, and atlas sources
│       └── ui/                              # HUD, menus, buttons, and upgrade art
└── README.md                                # Extra native-port notes
```

The root-level Godot files remain in the repo as reference material. They are not required to build or run the native iOS app.

## Development Notes

- Keep gameplay behavior intact when optimizing performance; prefer pooling and cosmetic budgets over reducing enemies, bullets, bosses, damage, or upgrades.
- Generated UI assets should remain modular so labels and dynamic numbers stay live in SpriteKit.
- Keep build products out of source control. Local folders such as `native-ios/DerivedData*/` and `native-ios/SwiftModuleCache/` are ignored.
- The current visual target is a readable, semi-cartoony bloodstream with ornate immune-themed UI, bright arcade feedback, and stable 60 FPS on the iPhone 17 Pro simulator.
