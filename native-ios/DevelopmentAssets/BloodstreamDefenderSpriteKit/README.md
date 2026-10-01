# Bloodstream Defender development assets

This directory preserves source art, alternates, candidates, previews, unused
audio, and Godot import metadata that are not loaded by the native SpriteKit
app. It deliberately sits outside
`BloodstreamDefenderSpriteKit/Assets`, because that directory is copied into the
app bundle as a folder resource.

The shipped runtime asset folder is a whitelist derived from `GameScene.swift`:

- `audio/`: every file named by `AudioCue.file`
- `backgrounds/parallax/source/layer-00-far-vessel-wash.png`
- `backgrounds/parallax/processed/`: the five layers named by
  `Constants.parallaxLayers`
- `sprites/processed/`: the eight sprite sheets loaded by `loadTextures()`
- `ui/`: the seventeen UI textures loaded by `loadTextures()`

When promoting a development asset into the app, copy only the final runtime
file into `BloodstreamDefenderSpriteKit/Assets` and add or update its explicit
loader reference. Keep source files and unused variants here.
