# Bloodstream Defender 1.1 (15) — TestFlight release record

October 1, 2026. Scope: TestFlight beta distribution; no public App Store release.

## Build and delivery

- Source: [`45c0462712359c6849ce3ad0b9418b4fdade2758`](https://github.com/Niko2756/bloodstream-defender-game/commit/45c0462712359c6849ce3ad0b9418b4fdade2758), branch `bloodstream-defender-iosgame`.
- Version/build: **1.1 (15)**; bundle identifier `com.niko.bloodstreamdefender.spritekit`.
- Built a signed iPhoneOS archive with **Xcode 27**, then exported an App Store distribution IPA. Archive and distribution signatures were verified against the configured team, `Q6M3ZUXKX5`.
- Game Center capability is enabled. The exported distribution IPA has **`get-task-allow = false`**. The development-signed archive's provisioning profile is distinct from the distribution export.
- Archive and exported IPA each passed resource validation: **60 runtime assets, 48,728,909 bytes**, matching identifier/version and privacy manifest. These are raw resource bytes, not the TestFlight download size.
- Upload accepted: **October 1, 2026 at 15:40:51 UTC**. App Store Connect then showed **1.1 (15), Processing**.
- **Final TestFlight availability: Internal TestFlight group shows Testing with build 1.1 (15) attached; verified October 1, 2026 at approximately 15:47 UTC.**

What to Test notes were saved. The existing internal testing group was retained without expanding the audience. Availability is confirmed; installation on a physical phone is not yet verified. No external beta review or public App Store release was requested.

## Validation

- Fresh Release simulator build and signed device archive succeeded.
- Passed **25/25** gameplay/audio checks, **80/80** ability-control checks, **11/11** run-summary geometry checks and **11/11** package-validator fixtures.
- Leaderboard persistence/retry regressions passed; **14/14** production-sender checks passed using fake GameKit services. Automated tests did not submit live scores.
- Simulator checks covered gameplay, pause/resume, backgrounding, cold-launch run restoration, exact Dash/Pulse labels and run-summary actions. Focused iPhone/iPad action checks covered both landscape orientations.
- Physical-device tilt, haptics, sustained performance, authenticated Game Center delivery and full six-boss/late-run coverage remain beta-test work. GitHub has no configured Actions/check runs; no CI pass is claimed.

See the [maintenance review](maintenance-1.1-review-2026-10-01.md) for scope and test limitations.

## What to Test

- Check that Dash and Pulse labels stay readable when locked, ready and cooling down, using both control styles and landscape orientations.
- From the run summary, confirm Try Again starts a new run and Main Menu returns to the title screen; check that labels and touch areas align.
- Pause and resume during a boss warning and immediately after clearing a section. Check music and effects, including mute/unmute.
- Background the app during a run, return, then close and reopen it. Confirm saved progress resumes safely from pause.
- Complete runs while offline, reconnect and sign into Game Center. Check that best score and highest level are retained independently and eventually appear on their leaderboards.
- On a physical device, test tilt calibration, both landscape orientations, touch controls, haptics and Motion Comfort. Report the device model, OS version and steps for any problem.
