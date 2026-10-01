#!/usr/bin/env python3
"""Compile actual GameScene method bodies against narrow host-side Swift fakes.

No Xcode project build, Simulator, iOS UI, audio device, or project writes occur.
The fakes supply state and platform boundaries; production methods under test are
extracted verbatim, including their access modifiers and control flow. This tests
logic, not SpriteKit rendering, AVAudioPlayer behavior, or iOS lifecycle delivery.

Usage:
  python3 review-tools/test_maintenance.py
  python3 review-tools/test_maintenance.py --compare-baseline GameScene.before-maintenance.swift
  python3 review-tools/test_maintenance.py --source /path/to/GameScene.swift
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import tempfile
from pathlib import Path

DEFAULT_SOURCE = Path(__file__).resolve().parents[1] / 'BloodstreamDefenderSpriteKit/GameScene.swift'


def method(source: str, name: str) -> str:
    """Extract one uniquely named Swift method, respecting comments and strings."""
    pattern = re.compile(r'^\s*(?:(?:private|fileprivate|public|internal|override|final)\s+)*func\s+' + re.escape(name) + r'\s*\(', re.M)
    matches = list(pattern.finditer(source))
    if len(matches) != 1:
        raise ValueError(f'Expected exactly one method named {name}, found {len(matches)}')
    start = matches[0].start()
    opening = source.index('{', matches[0].end())
    depth, i = 1, opening + 1
    while i < len(source):
        if source.startswith('//', i):
            i = source.find('\n', i)
            if i < 0:
                break
        elif source.startswith('/*', i):
            comments = 1
            i += 2
            while comments and i < len(source):
                if source.startswith('/*', i):
                    comments += 1
                    i += 2
                elif source.startswith('*/', i):
                    comments -= 1
                    i += 2
                else:
                    i += 1
        elif source[i] == '"':
            # Extracted methods have ordinary strings only; fail closed if changed.
            if source.startswith('"""', i):
                raise ValueError(f'Multiline literal needs parser support in {name}')
            i += 1
            while i < len(source):
                if source[i] == '\\':
                    i += 2
                elif source[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
        elif source[i] == '{':
            depth += 1
            i += 1
        elif source[i] == '}':
            depth -= 1
            i += 1
            if depth == 0:
                return source[start:i].strip()
        else:
            i += 1
    raise ValueError(f'Unterminated method {name}')


def constant(source: str, name: str) -> str:
    match = re.search(r'^\s*static let ' + re.escape(name) + r'\b[^\n]+', source, re.M)
    if not match:
        raise ValueError(f'Missing production constant {name}')
    return match.group().strip()


PRELUDE = r'''
import Foundation
import CoreGraphics

var failures: [String] = []
var checks = 0
func expect(_ condition: @autoclosure () -> Bool, _ name: String) {
    checks += 1
    if condition() { print("PASS \(name)") }
    else { failures.append(name); print("FAIL \(name)") }
}

enum EnemyKind { case basic, fast, tank, budding, influenza, fragment, bossDecoy, boss }
enum BossKind { case pox, norovirus }
final class SKSpriteNode {
    var position = CGPoint.zero
    var size = CGSize(width: 40, height: 40)
    var zRotation: CGFloat = 0
    var removed = false
    func removeFromParent() { removed = true }
}
final class Enemy {
    let id: Int
    var kind: EnemyKind
    var bossKind: BossKind? = nil
    let node = SKSpriteNode()
    var position: CGPoint
    var velocity = CGVector.zero
    var baseSpeed: CGFloat = 0
    var radius: CGFloat = 20
    var hp: CGFloat = 10
    var maxHP: CGFloat = 10
    var score = 10
    var reproductionCooldown: TimeInterval = 0
    var bossActionTimer: TimeInterval = 0
    var deathAnimationActive = false
    var dead = false
    init(_ id: Int, _ x: CGFloat, _ y: CGFloat, kind: EnemyKind = .basic) {
        self.id = id; self.position = CGPoint(x: x, y: y); self.kind = kind
    }
}
struct Player { var position = CGPoint(x: 600, y: 360) }
enum AudioCue: Hashable { case bossWarning, upgrade, menu
    var volume: Float { 0.75 }
}
final class FakePlayer {
    var isPlaying = true
    var currentTime: TimeInterval = 2.75
    var volume: Float = 0.75
    var plays = 0
    var pauses = 0
    var stops = 0
    func play() { plays += 1; isPlaying = true }
    func pause() { pauses += 1; isPlaying = false }
    func stop() { stops += 1; isPlaying = false }
}
enum GameMode { case title, running, levelComplete, paused, upgrade, gameOver }
final class AudioRecorder {
    var music: [AudioCue] = []
    var ambienceStarts = 0
    var ambienceStops = 0
    func playMusic(_ cue: AudioCue) { music.append(cue) }
    func playAmbience() { ambienceStarts += 1 }
    func stopAmbience() { ambienceStops += 1 }
}
'''

TARGET_FIXTURE = r'''
final class CombatHarness {
    var enemies: [Enemy] = []
    var player = Player()
    var lockTargetId: Int? = nil
    func visibleBaseMaxX() -> CGFloat { 1280 }
    func visibleBaseMinX() -> CGFloat { 0 }
    // These are neighboring system boundaries; cleanup operates on supplied state.
    func updateBoss(_ enemy: Enemy, delta: TimeInterval) {}
    func updateNorovirusDecoy(_ enemy: Enemy, delta: TimeInterval) {}
    func updateRegularEnemyAnimation(_ enemy: Enemy) {}
    func checkInfluenzaReplication(for enemy: Enemy) -> [(position: CGPoint, velocity: CGVector)] { [] }
    func spawnEnemy(kind: EnemyKind, position: CGPoint, velocity: CGVector) {
        preconditionFailure("Replication must not occur in cleanup fixtures")
    }

    func verify() {
        expect(findLockTarget() == nil, "target.empty has no target")
        let behind = Enemy(1, 100, 360, kind: .boss)
        let farOffLane = Enemy(2, 1200, 710)
        enemies = [behind, farOffLane]
        expect(findLockTarget() == nil, "target.all ineligible has no target")
        let valid = Enemy(3, 820, 360)
        enemies = [behind, farOffLane, valid]
        expect(findLockTarget()?.id == valid.id, "target.mixed retains eligible target")
        let dead = Enemy(4, 650, 360, kind: .boss); dead.dead = true
        let noHealth = Enemy(5, 650, 360, kind: .boss); noHealth.hp = 0
        let outsideViewport = Enemy(6, 2000, 360, kind: .boss)
        enemies = [dead, noHealth, outsideViewport, valid]
        expect(findLockTarget()?.id == valid.id, "target.dead empty-health offscreen excluded")
        let nearbyBehind = Enemy(7, 550, 360)
        enemies = [nearbyBehind]
        expect(findLockTarget()?.id == nearbyBehind.id, "target.nearby rear threat remains eligible")
        let farSameLane = Enemy(8, 1270, 360)
        enemies = [farSameLane]
        expect(findLockTarget()?.id == farSameLane.id, "target.long same-lane aim preserved")

        let escaped = Enemy(20, 1400, 360, kind: .bossDecoy)
        escaped.bossKind = .norovirus; escaped.bossActionTimer = 0
        enemies = [escaped]
        expect(activeNorovirusDecoyCount() == 1, "decoy.setup occupies slot")
        updateEnemies(delta: 0)
        expect(enemies.isEmpty && escaped.dead && escaped.node.removed,
               "decoy.launched right escape removed")
        expect(activeNorovirusDecoyCount() == 0, "decoy.right escape releases active slot")

        let onScreen = Enemy(21, 1200, 360, kind: .bossDecoy)
        onScreen.bossKind = .norovirus
        let orbiting = Enemy(22, 1400, 360, kind: .bossDecoy)
        orbiting.bossKind = .norovirus; orbiting.bossActionTimer = 0.5
        let enteringBoss = Enemy(23, 1600, 360, kind: .boss)
        enemies = [onScreen, orbiting, enteringBoss]
        updateEnemies(delta: 0)
        expect(enemies.count == 3, "decoy.visible orbiting and entering boss preserved")

        let leftEscape = Enemy(24, -100, 360, kind: .bossDecoy)
        leftEscape.bossKind = .norovirus
        enemies = [leftEscape]
        updateEnemies(delta: 0)
        expect(enemies.isEmpty && leftEscape.node.removed, "decoy.existing left cleanup preserved")
    }
    // INSERT_COMBAT_METHODS
}
'''

AUDIO_FIXTURE = r'''
final class SFXHarness {
    var sfxPlayers: [AudioCue: FakePlayer] = [:]
    var sfxPlaybackTokens: [AudioCue: Int] = [:]
    var pausedSFX = Set<AudioCue>()
    var sfxMuted = false
    func verify() {
        let warning = FakePlayer()
        sfxPlayers[.bossWarning] = warning
        pauseSFX(.bossWarning)
        pauseSFX(.bossWarning)
        expect(warning.pauses == 1, "sfx.double pause pauses player once")
        resumeSFX(.bossWarning)
        expect(warning.isPlaying && warning.plays == 1, "sfx.double pause resumes warning")
        expect(warning.currentTime == 2.75, "sfx.resume preserves playback position")
        resumeSFX(.bossWarning)
        expect(warning.plays == 1, "sfx.redundant resume does not restart")

        pauseSFX(.bossWarning)
        stopSFX(.bossWarning)
        let afterStop = warning.plays
        resumeSFX(.bossWarning)
        expect(!warning.isPlaying && warning.plays == afterStop && warning.currentTime == 0,
               "sfx.stop cancels paused playback")

        warning.isPlaying = true
        pauseSFX(.bossWarning)
        setSFXMuted(true)
        let afterMute = warning.plays
        resumeSFX(.bossWarning)
        expect(!warning.isPlaying && warning.plays == afterMute, "sfx.mute blocks resume")
        setSFXMuted(false)
        resumeSFX(.bossWarning)
        expect(!warning.isPlaying && warning.plays == afterMute, "sfx.unmute does not resurrect stale pause")

        pauseSFX(.bossWarning)
        resumeSFX(.bossWarning)
        expect(!warning.isPlaying, "sfx.idle pause does not start audio")
        pauseSFX(.menu)
        resumeSFX(.menu)
        expect(sfxPlayers[.menu] == nil, "sfx.missing cue remains harmless")
    }
    // INSERT_SFX_METHODS
}

final class MusicHarness {
    var mode: GameMode = .paused
    var pendingMusicCue: AudioCue? = .upgrade
    var pendingMusicTimer: TimeInterval = 0.55
    let audio = AudioRecorder()
    var desiredMusicCalls = 0
    func playDesiredMusic() { desiredMusicCalls += 1 }
    func shouldPlayVeinAmbience() -> Bool { mode == .running }
    func verify() {
        updateAudio(delta: 1)
        expect(pendingMusicCue == .upgrade && abs(pendingMusicTimer - 0.55) < 0.000001,
               "music.pause retains queued cue and remaining delay")
        expect(audio.music.isEmpty, "music.paused update never starts delayed cue")
        mode = .running
        updateAudio(delta: 0.25)
        expect(audio.music.isEmpty && pendingMusicCue == .upgrade,
               "music.resume respects remaining delay")
        updateAudio(delta: 0.31)
        expect(audio.music == [.upgrade] && pendingMusicCue == nil,
               "music.resume eventually plays queued cue once")
        updateAudio(delta: 0.1)
        expect(audio.music == [.upgrade] && desiredMusicCalls == 1,
               "music.after cue returns to ordinary routing")
    }
    // INSERT_MUSIC_METHOD
}
'''


def swift_program(source: str) -> tuple[str, list[str]]:
    audio_source = source[source.index('private final class AudioSystem {'):]
    combat = ['findLockTarget', 'enemyLockScore', 'updateEnemies', 'activeNorovirusDecoyCount',
              'liveEnemyCount', 'baseToStage', 'offscreenLeftRemovalX']
    sfx = ['pauseSFX', 'resumeSFX', 'stopSFX', 'setSFXMuted', 'nextSFXPlaybackToken']
    helpers = ['clamp', 'vectorLength', 'normalized', 'lerp']
    consts = ['baseSize', 'lockTargetRange', 'lockVerticalRange', 'maxActiveEnemies']
    parts = [PRELUDE, 'enum Constants {\n' + '\n'.join(constant(source, n) for n in consts) + '\n}',
             '\n'.join(method(source, name) for name in helpers),
             TARGET_FIXTURE.replace('// INSERT_COMBAT_METHODS', '\n'.join(method(source, n) for n in combat)),
             AUDIO_FIXTURE.replace('// INSERT_SFX_METHODS', '\n'.join(method(audio_source, n) for n in sfx))
                          .replace('// INSERT_MUSIC_METHOD', method(source, 'updateAudio')),
             'CombatHarness().verify()\nSFXHarness().verify()\nMusicHarness().verify()\n'
             'print("RESULT \\(checks - failures.count)/\\(checks) checks passed")\n'
             'exit(failures.isEmpty ? 0 : 1)\n']
    return '\n\n'.join(parts), combat + sfx + helpers + ['updateAudio']


def run(source_path: Path, swiftc: str, work_dir: Path, label: str) -> dict:
    raw = source_path.read_bytes()
    program, names = swift_program(raw.decode())
    generated = work_dir / (label + '.swift')
    binary = work_dir / label
    generated.write_text(program)
    compile_result = subprocess.run([swiftc, '-module-cache-path', str(work_dir / 'module-cache'),
                                     str(generated), '-o', str(binary)], text=True, capture_output=True, timeout=60)
    print(f'\n=== {label}: {source_path} ===')
    if compile_result.returncode:
        print(compile_result.stderr)
        raise RuntimeError(f'{label} harness failed to compile')
    result = subprocess.run([str(binary)], text=True, capture_output=True, timeout=15)
    print(result.stdout, end='')
    if result.stderr:
        print(result.stderr)
    return {'label': label, 'source': str(source_path), 'sha256': hashlib.sha256(raw).hexdigest(),
            'methods_extracted_verbatim': names, 'returncode': result.returncode,
            'output': result.stdout, 'compiler_warnings': compile_result.stderr}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=DEFAULT_SOURCE)
    parser.add_argument('--compare-baseline', type=Path)
    parser.add_argument('--swiftc', default='/usr/bin/swiftc')
    parser.add_argument('--report', type=Path, help='Write JSON evidence to this workspace path')
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix='bloodstream-maintenance-') as scratch:
        work_dir = Path(scratch)
        reports = []
        if args.compare_baseline:
            reports.append(run(args.compare_baseline.resolve(), args.swiftc, work_dir, 'baseline'))
        reports.append(run(args.source.resolve(), args.swiftc, work_dir, 'current'))
    if args.report:
        args.report.write_text(json.dumps({'scope': 'extracted production Swift logic with host fakes',
                                          'runs': reports}, indent=2) + '\n')
    current_passes = reports[-1]['returncode'] == 0
    baseline_fails = not args.compare_baseline or reports[0]['returncode'] != 0
    if args.compare_baseline:
        print(f'\nRegression comparison: baseline fails={baseline_fails}; current passes={current_passes}')
    return 0 if current_passes and baseline_fails else 1


if __name__ == '__main__':
    raise SystemExit(main())
