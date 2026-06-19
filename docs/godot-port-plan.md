# Godot Feature-Parity Port Plan

This repo now includes a Godot 4.6 project at the repository root. The existing web build remains intact, and Godot reuses the same `assets/` folder so the visual direction stays aligned with the current Bloodstream Defender prototype.

## Target

Build a feature-parity Godot version of Bloodstream Defender with the current game feel preserved:

- swim-like white blood cell movement
- threat-based antibody targeting
- Y-shaped antibody projectiles
- influenza replication behavior
- platelet hazards and red blood cell clutter
- level-complete flow
- roguelite upgrade tree
- pause, restart, music mute, and effects mute
- boss warning rumble followed by boss spawn and boss music
- late-stage boss and mini-boss encounters
- end-of-run summary

## First Godot Slice

The first Godot scene is `res://scenes/main.tscn` and the main script is `res://scripts/godot/main.gd`.

It currently establishes:

- Godot project settings and main scene
- reused bloodstream background and sprite assets
- player movement with inertia
- antibody firing and homing
- basic enemies, influenza replication, red cells, and platelets
- level flow, upgrade picks, pause menu, audio buses, and a game-over summary
- first-pass boss and mini-boss spawning model

This is intentionally a foundation, not the final port. The next pass should compare feel against the web version and then move toward exact parity.

## Next Porting Passes

1. Match player movement and firing timing against the current Phaser/WebGL build.
2. Replace placeholder Godot UI panels with the generated HUD, upgrade, pause, level-complete, and game-over art treatments.
3. Add touch controls and iOS-safe layout.
4. Port exact boss warning, boss phase, and late-level difficulty rules.
5. Split the large Godot script into reusable scenes: player, antibody shot, enemy, boss, level director, audio director, and UI director.
6. Add save/settings persistence for music and effects mute states.
7. Build and test on desktop from the Godot editor.
8. Export to iOS through Xcode once desktop feel is close enough.

## How To Open

1. Open Godot 4.6.
2. Choose **Import**.
3. Select `/Users/niko/Documents/Blood Cells Game/project.godot`.
4. Open the project.
5. Press **Play**.

The web version can still be served the old way with:

```bash
python3 -m http.server 8000
```

Then open `http://localhost:8000/`.
