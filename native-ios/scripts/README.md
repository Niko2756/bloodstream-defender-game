# Native maintenance checks

Run from the repository root on a Mac with the stable Xcode toolchain:

```sh
python3 native-ios/scripts/validate_runtime_assets.py --project-root native-ios
python3 native-ios/scripts/test_validate_runtime_assets.py
python3 native-ios/scripts/test_maintenance.py
python3 native-ios/scripts/test_control_labels.py
python3 native-ios/scripts/test_leaderboard_progress.py
python3 native-ios/scripts/test_game_center_sender.py
```

The Xcode target automatically runs the source asset check before compilation/resources. Script sandboxing stays enabled; `USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES=YES` lets Xcode declare the contents of the explicitly listed Assets input. The validator is read-only and uses Python's standard library.

After a fresh build, audit the actual bundle as well:

```sh
python3 native-ios/scripts/validate_runtime_assets.py --project-root native-ios --app '/path/to/BloodstreamDefenderSpriteKit.app' --json
```

This validates the exact runtime Assets inventory, identifier/version, and matching privacy manifest. It does not validate signing, App Store compliance, every file outside Assets, image appearance, audio quality, or real-device behavior. Keep development art in `native-ios/DevelopmentAssets`, outside the folder resource. If loader syntax changes, update the validator and its fixtures; do not disable the check to bypass an unexpected resource failure.

`test_maintenance.py` extracts actual production Swift methods and compiles them against narrow host platform fakes. Its 25 checks cover target eligibility, launched-decoy cleanup, audio pause/resume state, and delayed music. They do not replace SpriteKit/AVAudioPlayer or device tests. `--source` can select a captured baseline for comparison.

The leaderboard tests compile the production helper and sender logic with isolated test preferences and fake GameKit objects. They cover durable independent maxima, failed-submission retries, coalescing, logout/account changes, and stale callbacks. They never post live scores. Authenticated delivery still requires authorized device/account QA.

See `../../docs/maintenance-1.1-review-2026-10-01.md` for the audit, release notes, remaining risks, and iOS 27 test evidence. The legacy `ExportOptions-TestFlight.plist` uses `destination=upload`; do not use it for local-only verification.

`test_control_labels.py` exercises the production classic/native ability UI and activation methods in locked, ready, cooldown, paused, and hidden states. Its 80 checks preserve exact Dash/Pulse titles, visibility, availability, and activation guards. `--compare-baseline` additionally compares colors/glow against a captured source file. Simulator screenshots and action tests remain necessary for visual layout.
