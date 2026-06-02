# Parallax Backgrounds

Generated background layers live in `assets/backgrounds/parallax`.

## Layer Order

| Order | Layer | Runtime path | Speed | Alpha |
| --- | --- | --- | --- | --- |
| 0 | Far vessel wash | `assets/backgrounds/parallax/source/layer-00-far-vessel-wash.png` | `0.12x` | `1.0` |
| 1 | Plasma currents | `assets/backgrounds/parallax/processed/layer-01-mid-plasma-currents.png` | `0.28x` | `0.48` |
| 2 | Branch openings | `assets/backgrounds/parallax/processed/layer-02b-branch-openings.png` | `0.38x` | `0.36` |
| 3 | Distant red cells | `assets/backgrounds/parallax/processed/layer-02-distant-red-cells.png` | `0.52x` | `0.42` |
| 4 | Gameplay objects | canvas-drawn player, enemies, shots, hazards | `1.0x` gameplay space | `1.0` |
| 5 | Vessel wall foreground | `assets/backgrounds/parallax/processed/layer-03-foreground-vessel-walls.png` | `0.96x` | `1.0` |
| 6 | Near-camera floaters | `assets/backgrounds/parallax/processed/layer-04-foreground-floaters.png` | `1.22x` | `0.38` |

## Notes

- The far wash is opaque and should draw first.
- Other generated layers are transparent PNG overlays.
- Runtime tiling mirrors every other copy of each layer so the repeated edge connects cleanly instead of exposing mismatched left/right image edges.
- Foreground floaters intentionally move faster than gameplay to sell depth.
- If a layer appears too busy, lower its alpha in `drawBackground()` or `drawVesselForeground()`.
- If a chroma edge appears against the red backdrop, retry key removal with `--edge-contract 1` or regenerate that layer with a stronger flat key color.
