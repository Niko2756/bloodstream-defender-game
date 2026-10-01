#!/usr/bin/env python3
"""Compile and test the actual Foundation-only helper; no app, simulator, or live Game Center.

Uses a file-backed UserDefaults subclass inside TemporaryDirectory. It never reads or
writes the user's standard preferences. Pass --source to verify an integrated copy.
"""
import argparse
from pathlib import Path
import subprocess
import tempfile

SWIFT_TESTS = r'''
import Foundation

func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() { fatalError("FAIL: \(message)") }
}

final class TestDefaults: UserDefaults, @unchecked Sendable {
    let file: URL
    init(file: URL) {
        self.file = file
        super.init(suiteName: "BloodstreamReview-\(UUID().uuidString)")!
    }
    override func data(forKey key: String) -> Data? {
        check(key == "bloodstream.spritekit.gameCenter.leaderboardProgress.v1", "versioned isolated key")
        return try? Data(contentsOf: file)
    }
    override func set(_ value: Any?, forKey key: String) {
        check(key == "bloodstream.spritekit.gameCenter.leaderboardProgress.v1", "versioned isolated key")
        guard let data = value as? Data else { fatalError("Unexpected preference value") }
        try! data.write(to: file, options: .atomic)
    }
}

struct Call {
    let metric: LeaderboardMetric
    let value: Int
    let completion: (Error?) -> Void
}
final class Spy {
    var calls: [Call] = []
    func send(_ metric: LeaderboardMetric, _ value: Int, _ completion: @escaping (Error?) -> Void) {
        calls.append(Call(metric: metric, value: value, completion: completion))
    }
    var values: [String] { calls.map { "\($0.metric.rawValue)=\($0.value)" } }
}
let failure = NSError(domain: "LocalTest", code: 1)
let root = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
func defaults(_ name: String) -> TestDefaults { TestDefaults(file: root.appendingPathComponent(name + ".json")) }
func report(_ name: String) { print("PASS: \(name)") }

if CommandLine.arguments[1] == "seed" {
    let progress = LeaderboardProgress(defaults: defaults("process-restart"))
    progress.record(score: 1_000, level: 5)
    progress.record(score: 900, level: 6)
    report("write pending progress before login")
} else if CommandLine.arguments[1] == "recover" {
    let progress = LeaderboardProgress(defaults: defaults("process-restart"))
    let spy = Spy()
    progress.submitPending(for: "player-A", using: spy.send)
    check(spy.values == ["score=1000", "level=6"], "independent maxima survive real process restart")
    report("restart before login preserves divergent score/level maxima")
} else {
    do {
        let progress = LeaderboardProgress(defaults: defaults("defaults"))
        let spy = Spy()
        progress.submitPending(for: "player-A", using: spy.send)
        progress.record(score: -1, level: 0)
        progress.submitPending(for: "player-A", using: spy.send)
        check(spy.calls.isEmpty, "empty/invalid runs do not submit baseline values")
        progress.record(score: 100, level: 2)
        progress.submitPending(for: "", using: spy.send)
        check(spy.calls.isEmpty, "empty player ID does not submit")
        report("defaults, lower bounds, and missing player ID")
    }
    do {
        let store = defaults("divergent")
        let progress = LeaderboardProgress(defaults: store)
        progress.record(score: 1_000, level: 5)
        progress.record(score: 900, level: 6)
        progress.record(score: 100, level: 2)
        let spy = Spy()
        LeaderboardProgress(defaults: store).submitPending(for: "player-A", using: spy.send)
        check(spy.values == ["score=1000", "level=6"], "lower runs must not overwrite either maximum")
        report("divergent maxima and lower run preservation")
    }
    do {
        let store = defaults("failure")
        let progress = LeaderboardProgress(defaults: store)
        progress.record(score: 700, level: 4)
        var failures = 0
        progress.onSubmissionFailure = { _, _ in failures += 1 }
        let spy = Spy()
        progress.submitPending(for: "player-A", using: spy.send)
        spy.calls[0].completion(failure)
        spy.calls[1].completion(failure)
        check(spy.calls.count == 2 && failures == 2, "errors report once without immediate retry")
        // Recreate the coordinator to verify failures remain durable.
        let restarted = LeaderboardProgress(defaults: store)
        restarted.submitPending(for: "player-A", using: spy.send)
        check(spy.values == ["score=700", "level=4", "score=700", "level=4"], "failure retries after restart")
        spy.calls[2].completion(nil)
        spy.calls[3].completion(nil)
        let noRepeat = Spy()
        LeaderboardProgress(defaults: store).submitPending(for: "player-A", using: noRepeat.send)
        check(noRepeat.calls.isEmpty, "successful acknowledgments persist")
        report("durable failure, explicit retry, persisted successful acknowledgments")
    }
    do {
        let store = defaults("coalesce")
        let progress = LeaderboardProgress(defaults: store)
        let spy = Spy()
        progress.record(score: 100, level: 2)
        progress.submitPending(for: "player-A", using: spy.send)
        progress.submitPending(for: "player-A", using: spy.send)
        check(spy.calls.count == 2, "duplicate submits do not duplicate in-flight requests")
        progress.record(score: 200, level: 5)
        progress.submitPending(for: "player-A", using: spy.send)
        check(spy.calls.count == 2, "new maximum waits while old request is in flight")
        spy.calls[0].completion(nil)
        spy.calls[1].completion(nil)
        check(spy.values == ["score=100", "level=2", "score=200", "level=5"], "success flushes newer desired value per metric")
        spy.calls[0].completion(nil)
        check(spy.calls.count == 4, "duplicate old callback cannot acknowledge/duplicate new request")
        spy.calls[2].completion(nil)
        spy.calls[3].completion(nil)
        let checkRestart = Spy()
        LeaderboardProgress(defaults: store).submitPending(for: "player-A", using: checkRestart.send)
        check(checkRestart.calls.isEmpty, "latest coalesced values acknowledged durably")
        report("in-flight coalescing and duplicate submission/completion suppression")
    }
    do {
        let store = defaults("switch")
        let progress = LeaderboardProgress(defaults: store)
        let spy = Spy()
        var failures = 0
        progress.onSubmissionFailure = { _, _ in failures += 1 }
        progress.record(score: 500, level: 3)
        progress.submitPending(for: "player-A", using: spy.send)
        progress.submitPending(for: "player-B", using: spy.send)
        check(spy.calls.count == 4, "account switch resubmits local maxima")
        spy.calls[0].completion(nil)
        spy.calls[1].completion(failure)
        check(failures == 0, "late previous-account error ignored")
        progress.submitPending(for: "player-B", using: spy.send)
        check(spy.calls.count == 4, "late callback does not clear current account's in-flight requests")
        spy.calls[2].completion(nil)
        spy.calls[3].completion(nil)
        let same = Spy()
        LeaderboardProgress(defaults: store).submitPending(for: "player-B", using: same.send)
        check(same.calls.isEmpty, "last player's acknowledgments survive restart")
        progress.submitPending(for: "player-A", using: spy.send)
        check(spy.calls.count == 6, "switching back resets acknowledgments")
        spy.calls[0].completion(nil)
        spy.calls[1].completion(failure)
        progress.submitPending(for: "player-A", using: spy.send)
        check(spy.calls.count == 6 && failures == 0, "A-B-A late callback is rejected by request token")
        spy.calls[4].completion(nil)
        spy.calls[5].completion(nil)
        report("account switch, A-B-A, late success/error, last-player persistence")
    }
    do {
        let store = defaults("in-flight-restart")
        var progress: LeaderboardProgress? = LeaderboardProgress(defaults: store)
        let abandoned = Spy()
        progress!.record(score: 300, level: 7)
        progress!.submitPending(for: "player-A", using: abandoned.send)
        progress = nil
        let recovered = LeaderboardProgress(defaults: store)
        let retry = Spy()
        recovered.submitPending(for: "player-A", using: retry.send)
        check(retry.values == ["score=300", "level=7"], "in-flight state is not mistaken for acknowledged after restart")
        report("restart during in-flight submission retries unacknowledged values")
    }
    do {
        let progress = LeaderboardProgress(defaults: defaults("synchronous"))
        progress.record(score: 50, level: 2)
        var values: [String] = []
        progress.submitPending(for: "player-A") { metric, value, completion in
            values.append("\(metric.rawValue)=\(value)")
            if metric == .score && value == 50 { progress.record(score: 60, level: 2) }
            completion(nil)
        }
        check(values == ["score=50", "score=60", "level=2"], "synchronous callback and reentrant record do not deadlock")
        report("synchronous completion and reentrant record")
    }
    do {
        let progress = LeaderboardProgress(defaults: defaults("mixed-failure"))
        let spy = Spy()
        progress.record(score: 10, level: 2)
        progress.submitPending(for: "player-A", using: spy.send)
        spy.calls[0].completion(failure)
        progress.record(score: 20, level: 3)
        spy.calls[1].completion(nil)
        check(spy.values == ["score=10", "level=2", "level=3"], "success in other metric does not immediately retry failed metric")
        progress.submitPending(for: "player-A", using: spy.send)
        check(spy.values.last == "score=20", "next explicit request submits failed metric's current maximum")
        report("independent per-metric retry and acknowledgment behavior")
    }
}
'''

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=Path(__file__).resolve().parents[1] / 'BloodstreamDefenderSpriteKit/LeaderboardProgress.swift')
    args = parser.parse_args()
    source = args.source.resolve(strict=True)
    with tempfile.TemporaryDirectory(prefix='bloodstream-leaderboard-tests-') as directory:
        temp = Path(directory)
        main_swift = temp / 'main.swift'
        main_swift.write_text(SWIFT_TESTS)
        executable = temp / 'tests'
        subprocess.run(['xcrun', 'swiftc', '-swift-version', '5', '-module-cache-path', str(temp / 'modules'), str(source), str(main_swift), '-o', str(executable)], check=True)
        for mode in ('seed', 'recover', 'tests'):
            subprocess.run([str(executable), mode, str(temp)], check=True)
    print(f'PASS: all host regressions against {source}')

if __name__ == '__main__':
    main()
