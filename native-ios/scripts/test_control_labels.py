#!/usr/bin/env python3
"""Execute production ability UI/action methods against lightweight Swift fakes.

Tests labels, visibility, lock/cooldown/mode guards, and retained visual states.
Actual method bodies are extracted verbatim; no SpriteKit/UI/device is started.
Requires sibling test_maintenance.py for source extraction.
"""
import argparse
import hashlib
import json
import re
import subprocess
import tempfile
from pathlib import Path
from test_maintenance import DEFAULT_SOURCE, constant, method

SWIFT = r'''
import Foundation
import CoreGraphics
var failures: [String] = []
var checks = 0
func expect(_ value: @autoclosure () -> Bool, _ message: String) {
    checks += 1
    if !value() { failures.append(message); print("FAIL \(message)") }
}
struct UIColor: Equatable {
    let red: CGFloat; let green: CGFloat; let blue: CGFloat; let alpha: CGFloat
    var rgba: [Double] { [Double(red), Double(green), Double(blue), Double(alpha)] }
}
let clear = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
final class Shape {
    var fillColor = clear; var strokeColor = clear
    var glowWidth: CGFloat = 0; var isHidden = false
}
final class Label { var text: String?; var fontColor = clear; var isHidden = false }
struct Player {
    var position = CGPoint(x: 210, y: 360)
    var velocity = CGVector.zero
    var dashTimer: TimeInterval = 0
    var dashCooldown: TimeInterval = 0
    var pulseCooldown: TimeInterval = 0
    var invulnerable: TimeInterval = 0
}
enum GameMode { case title, running, paused, levelComplete, upgrade, gameOver }
enum Cue { case dash, pulse, mediumImpact }
final class Audio { var calls = 0; func playSFX(_ cue: Cue) { calls += 1 } }
final class Haptics { var calls = 0; func play(_ cue: Cue) { calls += 1 } }
struct ActivePulse {
    let origin: CGPoint; let maxRadius: CGFloat; let rank: Int
    let life: TimeInterval; let visuals: [Int]
}
// INSERT_STATE
enum Constants {
// INSERT_CONSTANTS
}
// INSERT_HELPERS
var visualSnapshots: [String: [[Double]]] = [:]
final class Harness {
    var mode: GameMode = .running
    var dashRank = 0; var pulseRank = 0
    var player = Player()
    var shouldUseNativeCombatAbilityControls = false
    var controlsNode = Shape()
    var dashButton = Shape(); var pulseButton = Shape()
    var dashLabel: Label? = Label(); var pulseLabel: Label? = Label()
    var lastFacing = CGVector(dx: 1, dy: 0)
    var dashTrailTimer: TimeInterval = 0
    var activePulses: [ActivePulse] = []
    let audio = Audio(); let haptics = Haptics()
    func publishCombatAbilityControlState() {}
    func currentMovementVector() -> CGVector { CGVector(dx: 1, dy: 0) }
    func spawnPlayerWake(direction: CGVector, strength: CGFloat) {}
    func spawnSpark(at position: CGPoint, color: UIColor, count: Int) {}
    func addScreenShake(duration: TimeInterval, magnitude: CGFloat) {}
    func spawnPulseWave(at position: CGPoint, radius: CGFloat, rank: Int, life: TimeInterval) -> [Int] { [1] }

    func verifyTitles(native: Bool, phase: String, rank: Int, cooldown: TimeInterval) {
        shouldUseNativeCombatAbilityControls = native
        dashRank = rank; pulseRank = rank
        player.dashCooldown = cooldown; player.pulseCooldown = cooldown
        updateAbilityControls()
        let state = currentCombatAbilityControlState()
        let name = "\(native ? "native" : "classic").\(phase)"
        expect(dashLabel?.text == "Dash" && pulseLabel?.text == "Pulse", "\(name): classic exact title case")
        expect(state.dashTitle == "Dash" && state.pulseTitle == "Pulse", "\(name): native exact title case")
        expect(dashButton.isHidden == native && pulseButton.isHidden == native, "\(name): classic visibility")
        expect(state.isVisible == native, "\(name): native visibility")
        let ready = phase == "ready"
        expect(state.dashEnabled == (native && ready) && state.pulseEnabled == (native && ready), "\(name): enabled gating")
        expect(state.dashReady == ready && state.pulseReady == ready, "\(name): readiness")
        expect(state.dashUnlocked == (rank > 0) && state.pulseUnlocked == (rank > 0), "\(name): unlocked state")
        visualSnapshots[name] = [dashButton.fillColor.rgba, dashButton.strokeColor.rgba,
                                 dashLabel!.fontColor.rgba, [Double(dashButton.glowWidth)],
                                 pulseButton.fillColor.rgba, pulseButton.strokeColor.rgba,
                                 pulseLabel!.fontColor.rgba, [Double(pulseButton.glowWidth)]]
    }
    func verifyActivation(native: Bool, state: String) {
        shouldUseNativeCombatAbilityControls = native
        dashRank = state == "locked" ? 0 : 1
        pulseRank = dashRank
        mode = state == "paused" ? .paused : .running
        let initialCooldown: TimeInterval = state == "cooldown" ? 1.25 : 0
        player.dashCooldown = initialCooldown; player.pulseCooldown = initialCooldown
        if native {
            performNativeDashButtonPress(); performNativePulseButtonPress()
        } else {
            triggerDash(input: currentMovementVector()); triggerPulse()
        }
        let allowed = state == "ready"
        let name = "\(native ? "native" : "classic").\(state)"
        expect((player.dashTimer > 0) == allowed, "\(name): dash activation guard")
        expect((activePulses.count == 1) == allowed, "\(name): pulse activation guard")
        expect(audio.calls == (allowed ? 2 : 0) && haptics.calls == (allowed ? 2 : 0), "\(name): effects follow activation")
        if allowed {
            expect(player.dashCooldown > 0 && player.pulseCooldown > 0, "\(name): activation starts cooldowns")
            let pulseCount = activePulses.count
            triggerDash(input: currentMovementVector()); triggerPulse()
            expect(audio.calls == 2 && activePulses.count == pulseCount, "\(name): repeated press cannot bypass cooldown")
        } else {
            expect(player.dashCooldown == initialCooldown && player.pulseCooldown == initialCooldown, "\(name): blocked press preserves cooldowns")
        }
    }
    func verifyPausedAndMixed() {
        shouldUseNativeCombatAbilityControls = true
        dashRank = 1; pulseRank = 1; player.pulseCooldown = 1.25
        var state = currentCombatAbilityControlState()
        expect(state.dashEnabled && !state.pulseEnabled, "mixed: independent ability gating")
        mode = .paused; state = currentCombatAbilityControlState()
        expect(!state.isVisible && !state.dashEnabled && !state.pulseEnabled, "paused: no native ability activation")
        expect(state.dashTitle == "Dash" && state.pulseTitle == "Pulse", "paused: titles remain exact")
        mode = .running; controlsNode.isHidden = true; state = currentCombatAbilityControlState()
        expect(!state.isVisible && !state.dashEnabled && !state.pulseEnabled, "hidden: native controls remain inactive")
    }
// INSERT_METHODS
}
for native in [false, true] {
    for (phase, rank, cooldown) in [("locked", 0, 0.0), ("ready", 1, 0.0), ("cooldown", 1, 1.25)] {
        Harness().verifyTitles(native: native, phase: phase, rank: rank, cooldown: cooldown)
    }
    for state in ["locked", "ready", "cooldown", "paused"] { Harness().verifyActivation(native: native, state: state) }
}
Harness().verifyPausedAndMixed()
print("SNAPSHOTS " + String(data: try! JSONSerialization.data(withJSONObject: visualSnapshots, options: [.sortedKeys]), encoding: .utf8)!)
print("RESULT \(checks - failures.count)/\(checks) checks passed")
exit(failures.isEmpty ? 0 : 1)
'''

def generate(source):
    state = re.search(r'struct CombatAbilityControlState: Equatable\s*\{[^{}]*\}', source)
    if not state:
        raise ValueError('Production state declaration not found')
    constants = ['dashDuration', 'pulseBaseRadius', 'pulseRadiusPerRank', 'pulseCooldown',
                 'pulseBaseLife', 'pulseRankLifeBonus', 'maxUpgradeRank']
    helpers = ['clamp', 'vectorLength', 'normalized', 'limit']
    methods = ['updateAbilityControls', 'currentCombatAbilityControlState', 'applyNativeAbilityControlVisibility',
               'triggerDash', 'triggerPulse', 'performNativeDashButtonPress', 'performNativePulseButtonPress',
               'updateHorizontalFacing', 'pulseLife', 'pulseRankBoost']
    return (SWIFT.replace('// INSERT_STATE', state.group())
            .replace('// INSERT_CONSTANTS', '\n'.join(constant(source, n) for n in constants))
            .replace('// INSERT_HELPERS', '\n'.join(method(source, n) for n in helpers))
            .replace('// INSERT_METHODS', '\n'.join(method(source, n) for n in methods)))

def run(path, scratch, label):
    source = path.read_text()
    swift = scratch / (label + '.swift'); binary = scratch / label
    swift.write_text(generate(source))
    compiled = subprocess.run(['/usr/bin/swiftc', '-module-cache-path', str(scratch / 'cache'), str(swift), '-o', str(binary)],
                              text=True, capture_output=True, timeout=60)
    if compiled.returncode:
        raise RuntimeError(compiled.stderr)
    tested = subprocess.run([str(binary)], text=True, capture_output=True, timeout=15)
    snapshots = next(line[len('SNAPSHOTS '):] for line in tested.stdout.splitlines() if line.startswith('SNAPSHOTS '))
    output = '\n'.join(line for line in tested.stdout.splitlines() if not line.startswith('SNAPSHOTS '))
    initial = {ability: re.search(r'let ' + ability + r'Label = label\("([^"]+)"', method(source, 'setupControls')).group(1)
               for ability in ['dash', 'pulse']}
    initial_ok = initial == {'dash': 'Dash', 'pulse': 'Pulse'}
    print(f'\n=== {label} ===\n{output}\nInitial captions: {initial}; exact={initial_ok}')
    return {'label': label, 'source': str(path), 'sha256': hashlib.sha256(source.encode()).hexdigest(),
            'returncode': tested.returncode, 'output': output, 'compiler_warnings': compiled.stderr,
            'initial_captions': initial, 'initial_captions_pass': initial_ok, 'visual_snapshots': json.loads(snapshots)}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=DEFAULT_SOURCE)
    parser.add_argument('--compare-baseline', type=Path)
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    runs = []
    with tempfile.TemporaryDirectory(prefix='bloodstream-control-labels-') as scratch:
        if args.compare_baseline:
            runs.append(run(args.compare_baseline, Path(scratch), 'baseline'))
        runs.append(run(args.source, Path(scratch), 'current'))
    visual_unchanged = len(runs) == 1 or runs[0]['visual_snapshots'] == runs[-1]['visual_snapshots']
    print(f'Colors and glow unchanged from baseline: {visual_unchanged}')
    if args.report:
        args.report.write_text(json.dumps({'scope': 'extracted production ability UI/activation methods with platform fakes',
                                          'visual_state_unchanged': visual_unchanged, 'runs': runs}, indent=2) + '\n')
    current_ok = runs[-1]['returncode'] == 0 and runs[-1]['initial_captions_pass']
    baseline_fails = len(runs) == 1 or runs[0]['returncode'] != 0 or not runs[0]['initial_captions_pass']
    return 0 if current_ok and baseline_fails and visual_unchanged else 1

if __name__ == '__main__':
    raise SystemExit(main())
