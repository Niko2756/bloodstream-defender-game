# Asset Pipeline

## Recommended Workflow

Use the generated concept image as the style reference, then create focused sprite sheets instead of one huge mixed-color sheet.

Best sheet split:

- `white-blood-cell`: swim frames, hurt frame, dash frame.
- `viruses-green`: green enemy body frames and expressions.
- `viruses-purple`: purple enemy body frames and expressions.
- `red-blood-cells`: obstacle/background cells at several angles and sizes.
- `platelets`: clustered yellow hazard sprites.
- `antibodies`: cyan projectile frames and impact pop frames.
- `eye-overlays`: optional pupils, eyelids, and eyebrows for code-driven eye movement.

## Why Split Sheets?

Transparent cleanup works best when the chroma-key color is far from the sprite colors. A single atlas with green, purple, red, yellow, white, and cyan assets forces a compromise and can create color fringing.

Recommended chroma colors:

- Use `#00ff00` for white blood cells, purple viruses, red blood cells, platelets, and cyan antibodies.
- Use `#ff00ff` for green viruses.

## Eye Animation

The most flexible approach is to draw the eyes in code:

- Use generated enemy body sprites as the base.
- Draw white eye shapes, pupils, and eyebrows as separate code or overlay sprites.
- Offset pupils toward the player or the current movement direction.
- Swap eyebrow/mouth overlays for angry, stunned, hurt, and defeated states.

This gives us lively eyes without needing a separate generated frame for every possible gaze direction.

## Current Generated Atlas

- Source: `assets/sprites/source/bloodstream-asset-atlas-source.png`
- Transparent, no-despill version: `assets/sprites/processed/bloodstream-asset-atlas-transparent-no-despill.png`

The current atlas is integrated in `src/game.js` as a sliced sprite sheet for:

- White blood cell swim frames.
- Green and purple virus enemies.
- Red blood cell obstacles/background swimmers.
- Yellow platelet hazards.
- Cyan antibody projectile shots.

The next polish pass should still regenerate focused sheets and slice them into individual transparent sprites or fixed-grid frames. That will reduce color fringing and make animation timing easier to tune.

## Current Background Layers

See `docs/parallax-backgrounds.md`.
