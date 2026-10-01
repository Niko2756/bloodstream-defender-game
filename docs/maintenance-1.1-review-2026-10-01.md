# Bloodstream Defender — renewed review and 1.1 maintenance plan

Reviewed October 1, 2026. Native project: `/Users/niko/Documents/Blood Cells Game/native-ios/BloodstreamDefenderSpriteKit.xcodeproj`.

The native SpriteKit app is the correct update target. Its existing, unfinished local update was already **1.1 (15)**; Git HEAD `9f7595e` is **1.0 (14)**. Five additional correctness fixes are now applied, with resource auditing added to the build and the requested ability-label/run-summary alignment corrections. No assets were deleted by this review, and no signing, accounts, entitlements, App Store publishing or uploads were changed. The user subsequently authorized committing and pushing the verified native update to its existing GitHub branch.

## Recovered context and project boundary

The registered Codex project is **Blood Cells Game**, at `/Users/niko/Documents/Blood Cells Game`. The root also contains historical Phaser/web and Godot implementations, a promotional site, source artwork, and App Store artwork. Those are distinct from the native UIKit/SpriteKit target. `docs/ios-app-store-port.md` describes an older Godot export and must not be used as the current native release procedure.

The earlier discussion has now been recovered: **Plan pre-September game update** (user-provided discussion; permalink retained in local review evidence). Its implemented 1.1 work matches the unfinished local update found at the start of this review. This supersedes the initial report's statement that the discussion was unavailable. The table below separates that earlier work from today's additional maintenance fixes.

| Recovered prior 1.1 work | What current source independently confirms | Remaining evidence limit |
|---|---|---|
| Smaller runtime package | Exactly 60 runtime files; 82 relocated tracked files preserved by SHA-256; 73,170,054 fewer raw bytes (69.8 MiB, about 60%) than Git HEAD. `DevelopmentAssets/.../README.md` documents the boundary. | The actual App Store upload inventory remains unknown. |
| Cached, state-driven animation | `GameScene.loadTextures`, `cachedTextures`, `updateRegularEnemyAnimation`, and `setBossTexture` retain frame textures; player state selects idle/swim/attack/dash frames and avoids changing an unchanged texture. | No measured frame-time or energy improvement is established by code inspection. |
| Persistent first-run and ability coaching | `PlayerProfileStore` saves three coaching flags; `beginFirstRunCoachingIfNeeded`, `updateCoachMessages`, and `enqueuePendingUnlockCoachingIfNeeded` queue guidance and persist completion. | Full interruption/relaunch and all-upgrade coaching QA is still required. |
| MAIN MENU on the run summary | `setupGameOverOverlay` creates the button and the game-over touch route returns to title. | The latest correction aligns labels and hit targets; focused iPhone action tests have passed, with iPhone and iPad verification recorded below. |
| Motion Comfort and sensor lifecycle | `shouldReduceMotion` combines the saved option with system Reduce Motion; animation/flash/shake branches reduce effects. `startMotionInputIfNeeded` and `stopMotionInput` control CoreMotion around gameplay/calibration/lifecycle. | This is not a claim that every motion effect is disabled; physical-device comfort, calibration and lifecycle tests remain. |
| Version and release declarations | Both configurations are already 1.1 (15); `Info.plist` has a motion-use description; `PrivacyInfo.xcprivacy` declares UserDefaults access and is a resource. | Latest App Store Connect build availability and privacy disclosures need release-owner verification. |

The recovered conversation reported a device build and static analyzer pass. Those are **historical reports**, not newly repeated device/analyzer evidence. Today's fresh Release simulator build, bundle audit, regression checks and simulator smoke results are listed separately below; they do not establish signed archive readiness or authenticated Game Center delivery.

Targeted project documents and Codex memory summaries also preserve these constraints:

- Preserve the approved V3 App Store How to Play artwork and the in-game V2 controls artwork. The V3 original is preserved in `native-ios/DevelopmentAssets/BloodstreamDefenderSpriteKit/Assets/ui/`; the V2 runtime file remains in the shipped Assets folder.
- Keep generated art modular, with live text and composable asset sheets.
- Audit developer shortcuts for release while retaining normal movement, shooting, dash, pulse, and pause controls. The current cheat shortcuts are already inside `#if DEBUG`; the Release binary lacks the debug boss banner string.

The earlier features and asset relocation were preserved rather than recreated. Today's new work is the five correctness fixes and resource validation below. Further architecture extraction, comprehensive tests, structured diagnostics, broader texture caching and in-app support/privacy access remain options; they are not all completed merely because they appeared in an earlier upgrade discussion.

## The extra-file concern

The Xcode target copies its entire native `Assets` folder. The historical committed tree includes source images, candidates, previews, and unused audio, so the concern has a real basis. The current unfinished cleanup already moves them outside the bundle.

| Evidence | Verified result |
|---|---|
| Git HEAD native Assets | 142 files; 121,898,963 bytes |
| Current native Assets | Exactly 60 referenced files; 48,728,909 bytes |
| Previously relocated material | 82 files; 73,170,054 bytes; every file preserved byte-for-byte by SHA-256 |
| Reduction in raw runtime resources | About 60.0% compared with Git HEAD |
| Fresh Release simulator app | 60 runtime resources; matching privacy manifest; version 1.1 (15) |
| Older local simulator app | 240 asset files, including 120 Godot `.import` files and development artwork; identifies as 0.1 (1) |

The older simulator app is not the App Store upload. The available `build/ios` archive is the legacy Godot product with a different bundle identifier. No native release archive or IPA was found in the scoped project/Xcode Archives locations, so the exact contents of the distributed binary remain unverified. The public [App Store listing](https://apps.apple.com/us/app/bloodstream-defender/id6784890545) showed 127.3 MB on the review date; this alone cannot establish its file inventory. Raw source bytes and an uncompressed simulator bundle are not App Store download-size estimates.

No further asset deletion is needed. The new `native-ios/scripts/validate_runtime_assets.py` derives the expected inventory from texture, parallax, medallion, and audio loader definitions. It rejects missing/unexpected runtime files, unsupported loader changes, and symlinks. Optional `--app` validation also checks the built identifier/version and privacy manifest. Xcode now runs the source check automatically with declared recursive inputs and script sandboxing retained. A fresh built-bundle audit remains part of the release procedure.

## Maintenance fixes completed in this review

| Fix | Trigger and resulting behavior | Code anchor |
|---|---|---|
| Reject ineligible antibody targets | When every enemy fails aiming eligibility, return no lock target instead of choosing a finite rejection score. Existing close-range and same-lane behavior is preserved. | `GameScene.swift`, `findLockTarget` / `enemyLockScore`, about lines 7146–7190 |
| Preserve warning sound across repeated pause calls | Normal resign-active then background callbacks no longer erase the saved boss-warning pause state. Explicit stop/mute still cancel playback. | `GameScene.swift`, `pauseSFX`, about line 7811 |
| Keep queued music paused | Pausing during the 0.55-second section-clear transition preserves its remaining delay. Music starts after resuming. | `GameScene.swift`, `updateAudio`, about line 6276 |
| Remove escaped Norovirus decoys | Launched decoys beyond the right edge now leave the active population, freeing decoy slots and their shield contribution. Orbiting decoys and entering bosses remain intact. | `GameScene.swift`, enemy cleanup, about line 4538 |
| Preserve offline Game Center records and retry failures | Independent score/level maxima persist before submission; only successful values are acknowledged. Authentication, run completion, and foreground events retry pending values. In-flight requests are deduplicated, newer values coalesce, and late callbacks/account changes cannot reuse the wrong identity. | `LeaderboardProgress.swift`; `GameScene.swift`, `GameCenterService.retryPendingScores` |

The fixes are deliberately small and do not rebalance enemy probabilities, change progression, or rewrite restoration.

The requested UI corrections are applied: both classic and native controls display exactly **Dash** and **Pulse** in locked, ready and cooldown states. Existing colors, availability guards and coaching remain. Run-summary labels and hit areas share symmetric centers 582 and 698, with width 112 each before panel scaling; the pill artwork and center divider are unchanged. Fresh Release build and extracted-method regressions pass. Focused simulator results are recorded below.

## Whole-project assessment

**Architecture.** The app now has five Swift source files, including the new small Foundation-only leaderboard persistence/coordinator. UIKit supplies the window, lifecycle, keyboard input, and native glass controls; a roughly 7,900-line `GameScene` combines rules, entities, menus, persistence, Game Center, audio, and rendering. This is workable for the current game, but increases regression risk. There are no external package dependencies in the native target. Keep the engine and gradually extract small services rather than rewrite the app.

**Gameplay.** Six boss profiles, staged warnings, swept shot collisions, three four-rank upgrade tracks, capped enemy populations, and continuous level scaling are implemented. The ordinary budding-enemy selection branch is unreachable: the earlier influenza condition catches the same random range (`pickEnemyKind`, about line 4344). Boss-driven budding spawns still work. Correcting the ordinary mix requires a balance decision, so it is recorded rather than silently changed.

**Rendering and efficiency.** Existing code already pools shots and spark nodes, caps cosmetic particles, reduces effects under load, and caches sprite-frame textures. Preserve these strengths. The main remaining candidates are repeated HUD/string/color updates, configuring hidden classic controls, duplicate native button configuration, eager texture/audio preparation, and blended parallax/effects. These are source observations, not measured performance bottlenecks. The 31 runtime PNGs represent about 111.7 MiB at base RGBA8 dimensions; that is an estimate, not resident or GPU memory. Audio files occupy about 26.9 MB. Profile before resizing/compressing art or changing loading strategy.

The prior subtexture cache is partial: player, ordinary-virus, boss and antibody frame arrays are reused, while `regionTexture` still constructs `SKTexture(rect:in:)` wrappers for red cells, platelets, UI elements, fallback paths and each Norovirus decoy batch. This operation defines a subregion of an existing texture; the source does not demonstrate that each call copies the full image. Cache those stable regions only if allocation profiling justifies it. Extraction is likewise partial: `LeaderboardProgress.swift` is now separate, but `PlayerProfileStore`, `AudioSystem`, `GameCenterService`, entities and rendering remain embedded in `GameScene.swift`.

**Persistence and lifecycle.** Checkpoints cover run statistics, health, upgrades, level progress, and important boss state. Relaunch restores to a paused game, which passed the iOS 27 smoke test. Restoration intentionally reconstructs the encounter: ordinary enemies/projectiles disappear, cooldowns reset, and boss attack phases are rebuilt. This is a forgiving resume policy with leaderboard implications. New checkpoint fields need backward-compatible decoding or migration; synthesized decoding of added required fields can discard old saves. There is no periodic combat checkpoint, so a crash can lose progress since the last lifecycle/state save.

**Game Center.** The old implementation persisted only the highest-score run, so a lower-score run reaching a higher level could be discarded before authentication. The new `LeaderboardProgress` keeps independent maxima, persistent per-metric acknowledgments for the last authenticated player, and pending retry state. It preserves the existing best-run summary and seeds the new values from it. Previously discarded historical levels cannot be reconstructed. Account changes reset acknowledgments while retaining device-local maxima, consistent with the prior device-local profile policy. Failed sends are retained and logged, with retries at normal app events rather than a rapid polling loop. Tests cover restart, divergent maxima, duplicate requests, coalescing, independent failures, and account changes without contacting Game Center. Actual authenticated account delivery remains device QA.

**Controls and accessibility.** Motion Comfort and system Reduce Motion support are useful existing improvements. Only the native Dash/Pulse buttons expose explicit accessibility properties. Menus, instructions, upgrade cards, and sliders need accessible equivalents. Fixed 1280×720 scaling can reduce nominal 50-unit settings controls to roughly 27 points on a 390-point-high landscape viewport. Safe-area and minimum-target handling need a small-screen/iPad pass. Joystick/tilt vectors are normalized, making movement effectively full-speed beyond the deadzone; changing that should be a deliberate feel decision. Keyboard cancellation and tilt after a landscape flip deserve physical-device tests.

**Build/release posture.** The deployment floor is iOS 18, with native glass controls from iOS 26. Xcode 27 successfully compiled the app, and tests ran on installed **iOS 27.0 (24A434)**. The source privacy manifest and motion-use description are present; this review does not certify App Store privacy disclosures. The existing `ExportOptions-TestFlight.plist` sets `destination=upload`; do not use it for a local-only export. Before this review there was no native test target or CI gate. The new host regressions and resource preflight add useful coverage; they do not replace device QA.

**Support, privacy and diagnostics.** On October 1, the App Store's linked [privacy policy](https://niko2756.github.io/bloodstream-defender-site/privacy/) and the website's [support page](https://niko2756.github.io/bloodstream-defender-site/support/) both loaded. They identify `bloodstreamdefendersupport@gmail.com`; the policy describes Game Center and support-email handling and is dated July 1, 2026. The reviewed native Swift files contain no Privacy/Support URL or link-opening action, so adding easy in-app access is still a small usability option. No support message was sent and App Store Connect's support field was not inspected. Native logging is limited: the new Game Center retry path uses `NSLog`, while checkpoint coding and audio session/player setup largely use `try?`, and missing textures use a debug assertion. Add focused local diagnostics and timing signposts only when needed to diagnose failures/profile costs; no analytics or remote logging was introduced.

**Test coverage limits.** The current native target still has no XCTest target or CI workflow. Today's standard-library Python fixtures and extracted-production Swift regressions provide targeted checks, with a separate temporary simulator smoke harness. They are not full game coverage or a coverage-percentage claim: checkpoint schema compatibility, coaching completion, six-boss behavior, audio interruptions, tilt orientation and accessibility flows need further tests. Preserve the existing tests and add those scenarios incrementally before major service extraction.

## Options and recommended execution order

| Stage | Option and tradeoff | Completion evidence |
|---|---|---|
| 1 — current 1.1 candidate | Keep the existing asset cleanup and prior local update, plus the five fixes and build gate. Focused maintenance scope; does not resolve every backlog item. | Fresh Release inventory, 25 gameplay/audio logic checks, leaderboard persistence/sender regressions, 11 validator fixtures, iOS 27 smoke result |
| 2 — release QA to finish | Exercise legacy checkpoint fixtures and complete physical-device/account QA, including the newly fixed Game Center path. | Authenticated delivery and offline recovery notes, old-save restore, all-six-boss and device-matrix results |
| 3 — measured efficiencies | Capture launch time, memory, frame-time percentiles and sustained thermal behavior on a supported older phone and a current phone. Then deduplicate HUD/native-control updates; consider texture/audio changes only for demonstrated cost. | Comparable before/after captures with identical gameplay scenarios and unchanged gameplay |
| 4 — usability | Accessible menus/live instructions, minimum touch targets, safe-area layouts, keyboard cancellation and in-app support/privacy access; choose intended analog movement and motion-reduction scope. | VoiceOver menu flow, small landscape/iPad snapshots, working public links, tilt and interruption tests |
| 5 — larger update options | Incrementally extract profile/audio/Game Center/combat rules; add seeded scenarios. Separately choose new progression, late-run upgrades, enemies, or modes after pacing feedback. | Behavior-preserving tests between extractions and an explicit gameplay design brief |

For 1.1, avoid an atlas/engine migration, mass recompression, new monetization, or broad gameplay redesign. Those increase regression surface without current profiling evidence. Keep the twelve existing upgrade selections and six-boss design intact while evaluating late-run pacing.

## Validation and evidence

- Initial iOS 27 SDK Swift typecheck passed.
- Fresh Release simulator build passed; no Swift warnings. The only build warning was skipped App Intents metadata extraction because the app does not use that framework.
- **25/25** behavior checks pass using actual extracted Swift methods with platform fakes. The captured pre-change source passes **16/25**, with failures covering all four repaired behaviors.
- **11/11** package-validator fixture tests pass, including extra/missing resources, stale metadata, missing privacy, parser drift, and symlinks.
- Leaderboard regressions compile the actual production helper against isolated file-backed test preferences and fake senders. They cover separate process restart before login, divergent maxima, failed sends, successful acknowledgments, coalescing, account changes, and late callbacks; no test posts live scores.
- **14/14** production Game Center sender checks pass using fake GameKit objects and the real main queue. A negative control removing only the account guard fails seven checks, confirming logout and account-switch race coverage.
- **80/80** ability UI/activation checks pass, including exact Dash/Pulse titles in all states, classic/native visibility, and locked/cooldown/mode guards. Baseline source fails the expected label checks; its color/glow snapshots match the corrected source. **11/11** source geometry checks confirm symmetric labels/hit areas and unchanged frame/divider/action routing.
- Current source and fresh Release bundle both contain the exact 60-file runtime inventory and remain version **1.1 (15)**. Latest source build: `build-release-ui-corrections-final.log`.
- Dedicated iPhone 18 Pro simulator on **iOS 27.0 (24A434)** passed gameplay, pause/resume, background/activate, and cold-launch saved-run restoration. The active 3D Graffiti simulator was not operated.
- Five focused final UI runs pass on **iOS 27.0 (24A434)**: Try Again and Main Menu each on an isolated iPhone 18 Pro and iPad mini (A17 Pro), plus ready/cooldown Dash/Pulse on iPhone. Each run covers both landscape orientations; post-action new runs verify exact locked titles too. Full-screen screenshots were visually reviewed for clean labels and centered summary actions. The first cooldown test outlasted its combat fixture; its final rerun uses a longer ordinary encounter and shorter screenshot collection, with no app-code change.
- The QA phone's original app preferences were backed up and restored; synthetic checkpoints and records are confined to the dedicated signed-out QA devices. No authenticated leaderboard delivery is claimed.
- Test evidence is in `/Users/niko/Documents/Codex/2026-10-01/task/`: build logs, `review-tools/maintenance-regression-results.json`, `review-tools/packaging-evidence.json`, XCTest result bundles and simulator screenshots.

Remaining validation: physical-device tilt/haptics/audio, sustained frame pacing/thermal behavior, all six bosses and late-run play, the remaining small-screen/iPad layout matrix beyond these focused checks, iOS 18 fallback controls, real Game Center failure/recovery, and an archive/IPA content check before any submission. No live performance benchmark, current App Store artifact inventory, or account delivery test is claimed.

Evidence provenance: the recovered earlier discussion supplies the historical plan/completion claims; the current Swift/project/plist files and SHA-256 inventory independently confirm the retained implementation; today's logs, JSON inventories and screenshots support only their recorded source/build snapshots. The older conversation's reported device build/analyzer results must not be relabeled as tests run today.

## Draft 1.1 release notes

Smaller app resources with unused development artwork kept out of the game package. Improved antibody targeting, more reliable pause/resume audio, corrected Norovirus decoy cleanup, better preservation of offline Game Center results, consistently readable Dash/Pulse labels, and centered run-summary actions. The existing update also includes animation improvements, tilt-control refinements, Motion Comfort, and clearer first-run/ability guidance; complete their device QA before including these claims in submitted release notes.

This is a locally built and tested maintenance candidate. Confirm the latest App Store Connect version/build, preserve and include the untracked DevelopmentAssets and privacy manifest when committing, review the pending QA, and prepare a local signed archive only when that release step is authorized.
