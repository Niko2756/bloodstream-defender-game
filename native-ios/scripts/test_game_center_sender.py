#!/usr/bin/env python3
"""Exercise production Game Center sender logic with local, network-free fakes.

Uses actual retryPendingScores/submit method bodies, the production error enum,
leaderboard IDs, and the complete production LeaderboardProgress helper. Only
GKLocalPlayer/GKLeaderboard and the minimal RunRecord are faked. Real main-queue
callbacks are drained with Foundation's run loop. UserDefaults uses disposable
UUID suites, never the application's standard domain.

Run from anywhere; test_maintenance.py must remain alongside this script.
  python3 review-tools/test_game_center_sender.py --negative-control --report review-tools/game-center-sender-results.json
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import tempfile
from pathlib import Path

from test_maintenance import DEFAULT_SOURCE, constant, method


FIXTURE = r'''
import Foundation

var failures: [String] = []
var checks = 0
func expect(_ condition: @autoclosure () -> Bool, _ name: String) {
    checks += 1
    if condition() { print("PASS \(name)") }
    else { failures.append(name); print("FAIL \(name)") }
}

func drainMainQueue() {
    var reachedBarrier = false
    DispatchQueue.main.async { reachedBarrier = true }
    let deadline = Date().addingTimeInterval(2)
    while !reachedBarrier && Date() < deadline {
        _ = RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
    }
    precondition(reachedBarrier, "Main-queue drain timed out")
}

struct RunRecord { let score: Int; let level: Int }
final class GKLocalPlayer {
    static let local = GKLocalPlayer()
    var isAuthenticated = false
    var gamePlayerID = ""
}
enum GKLeaderboard {
    struct Call {
        let score: Int
        let playerID: String
        let authenticated: Bool
        let leaderboardID: String
        let completion: (Error?) -> Void
    }
    static var calls: [Call] = []
    static func submitScore(_ score: Int, context: Int, player: GKLocalPlayer,
                            leaderboardIDs: [String], completionHandler: @escaping (Error?) -> Void) {
        precondition(leaderboardIDs.count == 1)
        calls.append(Call(score: score, playerID: player.gamePlayerID,
                          authenticated: player.isAuthenticated,
                          leaderboardID: leaderboardIDs[0], completion: completionHandler))
    }
}

enum Constants {
    // INSERT_CONSTANTS
}
final class GameCenterHarness {
    let leaderboardProgress: LeaderboardProgress
    init(defaults: UserDefaults) { leaderboardProgress = LeaderboardProgress(defaults: defaults) }
    // INSERT_ERROR_ENUM
    // INSERT_METHODS
}

func withSuite(_ label: String, _ body: (UserDefaults) -> Void) {
    let suite = "bloodstream.sender-regression.\(label).\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    GKLeaderboard.calls = []
    GKLocalPlayer.local.gamePlayerID = "A"
    GKLocalPlayer.local.isAuthenticated = true
    body(defaults)
    drainMainQueue()
}

func values(_ calls: [GKLeaderboard.Call]) -> [String: Int] {
    var result: [String: Int] = [:]
    for call in calls { result[call.leaderboardID] = call.score }
    return result
}
let upgraded = [Constants.scoreLeaderboardID: 200, Constants.levelLeaderboardID: 7]

withSuite("logout") { defaults in
    let service = GameCenterHarness(defaults: defaults)
    service.submit(record: RunRecord(score: 100, level: 5))
    expect(GKLeaderboard.calls.count == 2, "logout.initial maxima queued once per leaderboard")
    let original = GKLeaderboard.calls
    service.submit(record: RunRecord(score: 200, level: 7))
    expect(GKLeaderboard.calls.count == 2, "logout.newer maxima coalesce during in-flight work")
    GKLocalPlayer.local.isAuthenticated = false
    original.forEach { $0.completion(nil) }
    drainMainQueue()
    expect(GKLeaderboard.calls.count == 2, "logout.late success never submits while signed out")
    expect(GKLeaderboard.calls.allSatisfy { $0.authenticated }, "logout.no unauthenticated facade call")
    service.retryPendingScores()
    expect(GKLeaderboard.calls.count == 2, "logout.explicit retry waits for authentication")

    // A fresh owner proves rejected coalesced values survived in persisted storage.
    let restored = GameCenterHarness(defaults: defaults)
    GKLocalPlayer.local.isAuthenticated = true
    restored.retryPendingScores()
    let retryCalls = Array(GKLeaderboard.calls.dropFirst(2))
    expect(retryCalls.count == 2 && values(retryCalls) == upgraded,
           "logout.recreated helper resubmits durable newer score and level")
    expect(retryCalls.allSatisfy { $0.playerID == "A" && $0.authenticated },
           "logout.restored retry targets authenticated original player")
    retryCalls.forEach { $0.completion(nil) }
    drainMainQueue()
    let afterSuccess = GKLeaderboard.calls.count
    restored.retryPendingScores()
    expect(GKLeaderboard.calls.count == afterSuccess, "logout.success acknowledgment prevents duplicates")
}

withSuite("switch") { defaults in
    let service = GameCenterHarness(defaults: defaults)
    service.submit(record: RunRecord(score: 100, level: 5))
    let original = GKLeaderboard.calls
    service.submit(record: RunRecord(score: 200, level: 7))
    expect(original.count == 2 && GKLeaderboard.calls.count == 2, "switch.setup has two in-flight A requests")

    // The same mutable local-player object changes identity before submitPending(B).
    GKLocalPlayer.local.gamePlayerID = "B"
    original.forEach { $0.completion(nil) }
    drainMainQueue()
    expect(GKLeaderboard.calls.count == 2, "switch.stale A sender cannot post under newly active B")

    service.retryPendingScores()
    let bCalls = Array(GKLeaderboard.calls.dropFirst(2))
    expect(bCalls.count == 2 && values(bCalls) == upgraded,
           "switch.authorized B retry submits both independent maxima")
    expect(bCalls.allSatisfy { $0.playerID == "B" && $0.authenticated },
           "switch.authorized retry consistently targets B")
    bCalls.forEach { $0.completion(nil) }
    drainMainQueue()
    let afterB = GKLeaderboard.calls.count

    // A duplicated stale completion must not erase or reopen B acknowledgments.
    original.forEach { $0.completion(nil) }
    drainMainQueue()
    service.retryPendingScores()
    expect(GKLeaderboard.calls.count == afterB, "switch.late duplicate A callbacks do not disturb B")
    let restored = GameCenterHarness(defaults: defaults)
    restored.retryPendingScores()
    expect(GKLeaderboard.calls.count == afterB, "switch.B acknowledgments persist across helper recreation")
}

print("RESULT \(checks - failures.count)/\(checks) checks passed")
exit(failures.isEmpty ? 0 : 1)
'''


def program(source: str, helper: str, negative_control: bool) -> str:
    error_enum = re.search(r'private enum ScoreSubmissionError: Error\s*\{[^{}]+\}', source)
    if not error_enum:
        raise ValueError('Production ScoreSubmissionError enum not found')
    retry = method(source, 'retryPendingScores')
    if negative_control:
        guard_pattern = re.compile(r'\s*guard GKLocalPlayer\.local\.isAuthenticated, GKLocalPlayer\.local\.gamePlayerID == playerID else \{\s*completion\(ScoreSubmissionError\.authenticationChanged\)\s*return\s*\}')
        retry, substitutions = guard_pattern.subn('', retry)
        if substitutions != 1:
            raise ValueError('Expected one production account guard for negative-control removal')
    test = (FIXTURE.replace('// INSERT_CONSTANTS', '\n'.join(constant(source, name) for name in ['scoreLeaderboardID', 'levelLeaderboardID']))
            .replace('// INSERT_ERROR_ENUM', error_enum.group())
            .replace('// INSERT_METHODS', method(source, 'submit') + '\n' + retry))
    return helper + '\n' + test


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=DEFAULT_SOURCE)
    parser.add_argument('--helper', type=Path, default=DEFAULT_SOURCE.with_name('LeaderboardProgress.swift'))
    parser.add_argument('--negative-control', action='store_true', help='Also prove removing only the sender guard causes failures')
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    source = args.source.read_text()
    helper = args.helper.read_text()
    runs = []
    with tempfile.TemporaryDirectory(prefix='bloodstream-game-center-sender-') as scratch:
        scratch_path = Path(scratch)
        for negative in ([True, False] if args.negative_control else [False]):
            label = 'unguarded-negative-control' if negative else 'production'
            swift = scratch_path / (label + '.swift')
            executable = scratch_path / label
            swift.write_text(program(source, helper, negative))
            compiled = subprocess.run(['/usr/bin/swiftc', '-module-cache-path', str(scratch_path / 'module-cache'),
                                       str(swift), '-o', str(executable)], text=True, capture_output=True, timeout=60)
            if compiled.returncode:
                print(compiled.stderr)
                raise RuntimeError(f'{label} compile failed')
            result = subprocess.run([str(executable)], text=True, capture_output=True, timeout=20)
            print(f'\n=== {label} ===\n{result.stdout}', end='')
            if result.stderr:
                print(result.stderr)
            runs.append({'label': label, 'returncode': result.returncode, 'output': result.stdout,
                         'compiler_warnings': compiled.stderr})
    evidence = {'scope': 'production helper and extracted production sender; mocked GameKit; real main queue; no live service calls',
                'source': str(args.source), 'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                'helper': str(args.helper), 'helper_sha256': hashlib.sha256(helper.encode()).hexdigest(), 'runs': runs}
    if args.report:
        args.report.write_text(json.dumps(evidence, indent=2) + '\n')
    passed = runs[-1]['returncode'] == 0
    if args.negative_control:
        passed = passed and runs[0]['returncode'] == 1
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
