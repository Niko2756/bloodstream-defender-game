# Bloodstream Defender New Chat Handoff

Use this file to continue the Bloodstream Defender Godot port in a fresh Codex chat without repeating the same mistakes.

## Project

- Workspace: `/Users/niko/Documents/Blood Cells Game`
- Current focus: Godot feature-parity version of Bloodstream Defender.
- Main runtime file: `scripts/godot/main.gd`
- Main scene: `scenes/main.tscn`
- Godot project file: `project.godot`

## Copy-Paste Prompt For New Chat

```text
Please continue the Bloodstream Defender Godot port in `/Users/niko/Documents/Blood Cells Game`.

First read `docs/new-chat-handoff-2026-06-16.md`, then inspect `scripts/godot/main.gd` and the current Godot scene before making changes.

Important context:
- This is the Godot port of the original browser game, not the old web version.
- The user wants the game to keep the Bloodstream Defender look: generated bloodstream art, polished generated menu/panel assets, live readable text, and arcade gameplay.
- Do not use full-screen ImageGen mockups as pasted UI screens.
- For ImageGen assets, use isolated asset sheets or sprite sheets with no normal background, preferably transparent or chroma-key removable, then compose the pieces in the game.
- Keep labels, numbers, and button text live in Godot unless the user explicitly asks for baked text.
- The active gameplay HUD has been the current trouble spot. Do not use giant full ornate HUD frames as score/health/progress panels; they looked cropped, oversized, and unprofessional.
- The latest direction is compact original-style gameplay HUD panels with small generated medallion/trim accents, not huge cropped ImageGen boxes.
- Before touching the HUD again, compare against the original compact HUD proportions and the user’s screenshots.

Please continue cautiously, verify visually where possible, and explain any tradeoffs before committing or publishing.
```

## Current State As Of This Handoff

The project is mid-port and the working tree is not clean. Many Godot files and generated assets are currently untracked because this branch/project was being built locally. Do not assume everything is committed.

Latest relevant active HUD change:

- The mission/objective box was removed from the active gameplay HUD.
- Score and health were changed back to compact original-style `_hud_panel` boxes.
- Generated medallion assets are used as small accents:
  - `HUD_ORN_SCORE`
  - `HUD_ORN_HEALTH`
- Level is back to a compact text panel.
- Pause uses a compact generated crop:
  - `assets/ui/hud-game-pause-compact-frame.png`
- Bottom progress uses a compact generated crop:
  - `assets/ui/hud-game-progress-compact-frame.png`

This was done because the full generated HUD frames were too big and looked cropped on screen.

## Recent HUD Assets

Generated/source assets from another chat:

- `assets/ui/hud-frame-asset-sheet-source-chroma.png`
- `assets/ui/hud-frame-asset-sheet-v2-source-chroma.png`
- `assets/ui/hud-frame-asset-sheet-v2.png`
- `assets/ui/hud-game-score-frame.png`
- `assets/ui/hud-game-health-frame.png`
- `assets/ui/hud-game-pause-frame.png`
- `assets/ui/hud-game-level-frame.png`
- `assets/ui/hud-game-progress-frame.png`

Compact crops created from those assets:

- `assets/ui/hud-game-score-compact-frame.png`
- `assets/ui/hud-game-health-compact-frame.png`
- `assets/ui/hud-game-pause-compact-frame.png`
- `assets/ui/hud-game-progress-compact-frame.png`

Only the compact pause/progress crops are currently referenced by `scripts/godot/main.gd`. The score/health compact crops exist but were not used because they still looked like cropped frame fragments.

## HUD Lessons Learned

Do not repeat these moves:

- Do not paste full-screen generated UI mockups into the game.
- Do not use huge ornate HUD frame images as active gameplay panels if their circular ends get cropped or dominate the playfield.
- Do not simply “make it smaller” if the underlying art shape is wrong.
- Do not replace readable live UI with baked labels unless specifically requested.
- Do not let the HUD cover the playfield. The user wants more visible game area.

Preferred approach for active gameplay HUD:

- Keep it compact and readable.
- Use generated assets as accents or slim trim.
- Preserve live text for score, health, level, pause, and progress.
- When an ImageGen asset does not fit, crop or generate a purpose-built compact asset rather than stretching a decorative panel.

## ImageGen Workflow Preference

When the user asks for ImageGen assets:

- Ask for an asset sheet / sprite sheet, not a full composition.
- Use a removable flat chroma-key background or transparent-style background.
- Keep objects isolated, padded, and non-overlapping.
- Remove chroma key locally if needed.
- Put text live in Godot unless baked text is explicitly desired and approved.

Useful chroma-key helper:

```bash
python3 /Users/niko/.codex/skills/.system/imagegen/scripts/remove_chroma_key.py \
  --input <source.png> \
  --out <transparent-output.png> \
  --auto-key border \
  --soft-matte \
  --transparent-threshold 18 \
  --opaque-threshold 220 \
  --despill
```

## Verification

Headless load/import commands used successfully:

```bash
mkdir -p /private/tmp/bloodstream-godot-home
HOME=/private/tmp/bloodstream-godot-home /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import
HOME=/private/tmp/bloodstream-godot-home /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 1
```

Known harmless-ish headless messages:

- macOS CA certificate warning.
- Sometimes a shutdown resource/leak warning from the headless run.

Important: a headless load check is not a visual QA pass. For UI work, inspect screenshots or run the project in Godot.

## Current Likely Next Step

The current active HUD should be visually checked in Godot. If it still looks bad:

1. Do not go back to giant generated HUD frames.
2. Start from the compact original-style HUD proportions.
3. Use smaller generated accents or create new purpose-built small HUD assets.
4. Keep the mission box removed unless the user asks for it back.
5. Keep the playfield clear.

## Git / Publishing Caution

The user often asks to commit and publish later, but do not do it unless explicitly asked in the new chat.

When committing:

- Stage explicit paths only.
- Do not blanket-add unrelated source/generated files.
- Verify which generated assets are actually referenced.
- The existing here.now site should be reused, not replaced with a new site.

