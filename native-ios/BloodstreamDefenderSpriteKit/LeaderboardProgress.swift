import Foundation

enum LeaderboardMetric: String, CaseIterable {
    case score
    case level
}

/// Device-local maxima and successful submissions for the last authenticated player.
/// The caller decides when to retry (authentication, end of run, foreground).
/// Sender and failure callbacks execute outside the lock and may complete synchronously.
final class LeaderboardProgress {
    private static let storageKey = "bloodstream.spritekit.gameCenter.leaderboardProgress.v1"

    private struct State: Codable {
        var version = 1
        var maxScore = 0
        var maxLevel = 1
        var acknowledgedScore = 0
        var acknowledgedLevel = 1
        var lastPlayerID: String?

        func desired(_ metric: LeaderboardMetric) -> Int {
            metric == .score ? maxScore : maxLevel
        }

        func acknowledged(_ metric: LeaderboardMetric) -> Int {
            metric == .score ? acknowledgedScore : acknowledgedLevel
        }

        mutating func acknowledge(_ metric: LeaderboardMetric, value: Int) {
            if metric == .score {
                acknowledgedScore = max(acknowledgedScore, value)
            } else {
                acknowledgedLevel = max(acknowledgedLevel, value)
            }
        }
    }

    private struct Request {
        let id = UUID()
        let metric: LeaderboardMetric
        let value: Int
        let playerID: String
    }

    private let defaults: UserDefaults
    private let lock = NSLock()
    private var state: State
    private var inFlight: [LeaderboardMetric: Request] = [:]
    private var failureHandler: ((LeaderboardMetric, Error) -> Void)?

    var onSubmissionFailure: ((LeaderboardMetric, Error) -> Void)? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return failureHandler
        }
        set {
            lock.lock()
            failureHandler = newValue
            lock.unlock()
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           var restored = try? JSONDecoder().decode(State.self, from: data),
           restored.version == 1 {
            restored.maxScore = max(0, restored.maxScore)
            restored.maxLevel = max(1, restored.maxLevel)
            restored.acknowledgedScore = min(restored.maxScore, max(0, restored.acknowledgedScore))
            restored.acknowledgedLevel = min(restored.maxLevel, max(1, restored.acknowledgedLevel))
            if restored.lastPlayerID?.isEmpty != false {
                restored.lastPlayerID = nil
                restored.acknowledgedScore = 0
                restored.acknowledgedLevel = 1
            }
            state = restored
        } else {
            state = State()
        }
    }

    func record(score: Int, level: Int) {
        lock.lock()
        defer { lock.unlock() }
        let nextScore = max(state.maxScore, score)
        let nextLevel = max(state.maxLevel, level)
        guard nextScore != state.maxScore || nextLevel != state.maxLevel else { return }
        state.maxScore = nextScore
        state.maxLevel = nextLevel
        persistLocked()
    }

    func submitPending(
        for playerID: String,
        using sender: @escaping (LeaderboardMetric, Int, @escaping (Error?) -> Void) -> Void
    ) {
        guard !playerID.isEmpty else { return }
        lock.lock()
        if state.lastPlayerID != playerID {
            state.lastPlayerID = playerID
            state.acknowledgedScore = 0
            state.acknowledgedLevel = 1
            inFlight.removeAll()
            persistLocked()
        }
        let requests = LeaderboardMetric.allCases.compactMap { reserveLocked($0, playerID: playerID) }
        lock.unlock()
        for request in requests {
            send(request, using: sender)
        }
    }

    /// Must be called under lock. A reservation also prevents duplicate concurrent sends.
    private func reserveLocked(_ metric: LeaderboardMetric, playerID: String) -> Request? {
        let value = state.desired(metric)
        let minimum = metric == .score ? 0 : 1
        guard inFlight[metric] == nil,
              value > minimum,
              value > state.acknowledged(metric) else { return nil }
        let request = Request(metric: metric, value: value, playerID: playerID)
        inFlight[metric] = request
        return request
    }

    private func send(
        _ request: Request,
        using sender: @escaping (LeaderboardMetric, Int, @escaping (Error?) -> Void) -> Void
    ) {
        // A synchronous completion of another metric can switch the account before
        // this queued reservation is sent. Drop it if it is no longer current.
        lock.lock()
        let isCurrent = state.lastPlayerID == request.playerID && inFlight[request.metric]?.id == request.id
        lock.unlock()
        guard isCurrent else { return }
        sender(request.metric, request.value) { [weak self] error in
            self?.complete(request, error: error, using: sender)
        }
    }

    private func complete(
        _ request: Request,
        error: Error?,
        using sender: @escaping (LeaderboardMetric, Int, @escaping (Error?) -> Void) -> Void
    ) {
        lock.lock()
        guard state.lastPlayerID == request.playerID,
              inFlight[request.metric]?.id == request.id else {
            lock.unlock()
            return
        }
        inFlight.removeValue(forKey: request.metric)
        if let error {
            let handler = failureHandler
            lock.unlock()
            // Leave the durable maximum unacknowledged. Do not immediately retry errors.
            handler?(request.metric, error)
            return
        }
        state.acknowledge(request.metric, value: request.value)
        persistLocked()
        // A better result recorded while this request was in flight is sent once now.
        let next = reserveLocked(request.metric, playerID: request.playerID)
        lock.unlock()
        if let next {
            send(next, using: sender)
        }
    }

    private func persistLocked() {
        // State contains only integers and a string, so JSON has no non-finite values.
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }
}
