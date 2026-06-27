import AVFoundation
import CoreMotion
import Foundation
import GameKit
import SpriteKit
import UIKit

private enum GameMode {
    case title
    case running
    case levelComplete
    case paused
    case upgrade
    case gameOver
}

private enum ZLayer {
    static let background: CGFloat = 0
    static let entity: CGFloat = 20
    static let projectile: CGFloat = 30
    static let particles: CGFloat = 40
    static let hud: CGFloat = 80
    static let controls: CGFloat = 90
    static let overlay: CGFloat = 120
}

private enum UpgradeChoice {
    case rapid
    case pulse
    case dash
}

private struct UpgradeRankInfo {
    let current: String
    let next: String
}

private struct UpgradeDefinition {
    let choice: UpgradeChoice
    let term: String
    let title: String
    let controls: String
    let body: String
    let ranks: [UpgradeRankInfo]
    let medallionName: String
    let accent: UIColor
}

private enum EnemyKind {
    case basic
    case fast
    case tank
    case budding
    case influenza
    case fragment
    case bossDecoy
    case boss
}

private enum BossKind {
    case pox
    case adenovirus
    case filovirus
    case rotavirus
    case lyssavirus
    case norovirus
}

private struct ParallaxLayerDefinition {
    let name: String
    let subdirectory: String
    let speed: CGFloat
    let alpha: CGFloat
}

private struct MissionDefinition {
    let name: String
    let term: String
    let target: String
    let isEncounter: Bool
    let bossKind: BossKind?
    let bossTarget: String?

    init(name: String, term: String, target: String, isEncounter: Bool, bossKind: BossKind? = nil, bossTarget: String? = nil) {
        self.name = name
        self.term = term
        self.target = target
        self.isEncounter = isEncounter
        self.bossKind = bossKind
        self.bossTarget = bossTarget
    }
}

private struct BossProfile {
    let title: String
    let kind: BossKind
    let frames: [SpriteFrame]
    let texture: SKTexture
    let radius: CGFloat
    let hp: CGFloat
    let score: Int
    let damage: CGFloat
    let damageScale: CGFloat
    let targetX: CGFloat
    let attackInterval: TimeInterval
    let visualScale: CGFloat
}

private struct Constants {
    static let baseSize = CGSize(width: 1280, height: 720)
    static let playerMaxHealth: CGFloat = 100
    static let playerSpeed: CGFloat = 270
    static let playerAccel: CGFloat = 4.4
    static let playerDrag: CGFloat = 3.2
    static let playerCollisionRadius: CGFloat = 34
    static let playerVisualScale: CGFloat = 0.42
    static let shotSpeed: CGFloat = 780
    static let shotLife: TimeInterval = 2.4
    static let shotHitRadius: CGFloat = 24
    static let shotHomingStrength: CGFloat = 7.5
    static let shotPoolLimit = 180
    static let sparkPoolLimit = 220
    static let cosmeticParticleSoftCap = 92
    static let cosmeticParticleHardCap = 136
    static let cosmeticSparkFrameBudget = 28
    static let cosmeticSparkFrameBudgetUnderLoad = 12
    static let cosmeticHitFlashFrameBudget = 14
    static let cosmeticHitFlashFrameBudgetUnderLoad = 5
    static let sparkNodeName = "pooledSpark"
    static let tiltCalibrationToastActionKey = "tiltCalibrationToast"
    static let tiltCalibrateButtonResetActionKey = "tiltCalibrateButtonReset"
    static let tiltSensitivitySliderWidth: CGFloat = 350
    static let tiltSensitivitySliderLeftX: CGFloat = 465
    static let tiltSensitivitySliderY: CGFloat = 446
    static let tiltSensitivityMin: CGFloat = 1.35
    static let tiltSensitivityDefault: CGFloat = 1.8
    static let tiltSensitivityMax: CGFloat = 3.35
    static let scoreLeaderboardID = "com.niko.bloodstreamdefender.spritekit.best_score"
    static let levelLeaderboardID = "com.niko.bloodstreamdefender.spritekit.highest_level"
    static let maxUpgradeRank = 4
    static let dangerMusicThreshold: CGFloat = 0.42
    static let dangerMusicResetRatio: CGFloat = 0.72
    static let redCellMaxActive = 16
    static let plateletMaxActive = 5
    static let bossWarningDuration: TimeInterval = 17.2
    static let bossPreClearDuration: TimeInterval = 3.2
    static let lockTargetRange: CGFloat = 640
    static let lockVerticalRange: CGFloat = 245
    static let joystickCenter = CGPoint(x: 138, y: 558)
    static let joystickRadius: CGFloat = 76
    static let joystickKnobRadius: CGFloat = 26
    static let joystickTouchRadius: CGFloat = 152
    static let joystickDeadzone: CGFloat = 0.13
    static let healthBarSize = CGSize(width: 318, height: 20)
    static let healthBarCenter = CGPoint(x: 503, y: 53)
    static let progressBarSize = CGSize(width: 626, height: 12)
    static let progressBarCenter = CGPoint(x: 640, y: 684)
    static let progressFrameSize = CGSize(width: 780, height: 48)
    static let maxActiveEnemies = 14
    static let maxNorovirusDecoys = 6
    static let levelClearDelay: TimeInterval = 0.7
    static let pulseBaseRadius: CGFloat = 180
    static let pulseRadiusPerRank: CGFloat = 42
    static let pulseEdgeGrace: CGFloat = 96
    static let pulseBaseLife: TimeInterval = 1.10
    static let pulseRankLifeBonus: TimeInterval = 0.12
    static let pulseExpansionRatio: CGFloat = 0.52
    static let dashSpeed: CGFloat = 680
    static let dashDuration: TimeInterval = 0.18
    static let dashCooldown: TimeInterval = 2.1
    static let pulseCooldown: TimeInterval = 4.8
    static let tiltDeadzone: CGFloat = 0.05
    static let tiltSmoothing: CGFloat = 9.0
    static let parallaxLayers = [
        ParallaxLayerDefinition(name: "layer-00-far-vessel-wash", subdirectory: "Assets/backgrounds/parallax/source", speed: 0.06, alpha: 1.0),
        ParallaxLayerDefinition(name: "layer-01-mid-plasma-currents", subdirectory: "Assets/backgrounds/parallax/processed", speed: 0.16, alpha: 0.88),
        ParallaxLayerDefinition(name: "layer-02-distant-red-cells-seam-clean", subdirectory: "Assets/backgrounds/parallax/processed", speed: 0.24, alpha: 0.62),
        ParallaxLayerDefinition(name: "layer-02b-branch-openings", subdirectory: "Assets/backgrounds/parallax/processed", speed: 0.34, alpha: 0.64),
        ParallaxLayerDefinition(name: "layer-03-foreground-vessel-walls", subdirectory: "Assets/backgrounds/parallax/processed", speed: 0.62, alpha: 1.0),
        ParallaxLayerDefinition(name: "layer-04-foreground-floaters-seam-clean", subdirectory: "Assets/backgrounds/parallax/processed", speed: 0.78, alpha: 0.42)
    ]
    static let missions = [
        MissionDefinition(name: "Innate Patrol", term: "Innate immunity", target: "virions", isEncounter: false),
        MissionDefinition(name: "Antigen Sweep", term: "Antigen", target: "antigens", isEncounter: false),
        MissionDefinition(name: "Complement Cascade", term: "Complement system", target: "virions", isEncounter: false),
        MissionDefinition(name: "Influenza Bloom", term: "Viral replication", target: "influenza virions", isEncounter: false)
    ]
    static let encounters = [
        MissionDefinition(name: "Pox-Brick Breach", term: "Poxvirus", target: "virions", isEncounter: true, bossKind: .pox, bossTarget: "pox boss"),
        MissionDefinition(name: "Adenovirus Prism", term: "Adenovirus", target: "virions", isEncounter: true, bossKind: .adenovirus, bossTarget: "adenovirus mini-boss"),
        MissionDefinition(name: "Filovirus Ribbon", term: "Filovirus", target: "virions", isEncounter: true, bossKind: .filovirus, bossTarget: "filovirus boss"),
        MissionDefinition(name: "Rotavirus Gyre", term: "Rotavirus", target: "virions", isEncounter: true, bossKind: .rotavirus, bossTarget: "rotavirus gyre"),
        MissionDefinition(name: "Lyssavirus Lance", term: "Rabies lyssavirus", target: "virions", isEncounter: true, bossKind: .lyssavirus, bossTarget: "lyssavirus lance"),
        MissionDefinition(name: "Norovirus Swarm-Core", term: "Norovirus", target: "virions", isEncounter: true, bossKind: .norovirus, bossTarget: "norovirus swarm-core"),
        MissionDefinition(name: "Adenovirus Prism", term: "Adenovirus", target: "virions", isEncounter: true, bossKind: .adenovirus, bossTarget: "adenovirus mini-boss")
    ]
    static let upgrades = [
        UpgradeDefinition(
            choice: .rapid,
            term: "IgG antibodies",
            title: "Rapid Antibody Factory",
            controls: "Use: Space, click, or tap.",
            body: "Improves antibody output with faster cooldowns, stronger hits, and extra projectiles.",
            ranks: [
                UpgradeRankInfo(current: "Faster cooldown", next: "Faster antibody cooldown"),
                UpgradeRankInfo(current: "Paired antibodies", next: "Fire paired antibodies"),
                UpgradeRankInfo(current: "Stronger paired hits", next: "Stronger hits, faster cooldown"),
                UpgradeRankInfo(current: "Triple spread, max output", next: "Triple antibody spread")
            ],
            medallionName: "upgrade-medallion-antibody",
            accent: UIColor(red: 0.45, green: 1.0, blue: 1.0, alpha: 1.0)
        ),
        UpgradeDefinition(
            choice: .pulse,
            term: "Complement proteins",
            title: "Complement Pulse",
            controls: "Use: E, Enter, or PULSE button.",
            body: "Emergency radial burst that clears nearby pathogens, breaks platelets, and scales against bosses.",
            ranks: [
                UpgradeRankInfo(current: "Pulse unlocked", next: "Unlock complement pulse"),
                UpgradeRankInfo(current: "Wider burst, stronger bosses", next: "Wider burst, stronger boss hit"),
                UpgradeRankInfo(current: "Faster recharge, longer wave", next: "Faster recharge, longer wave"),
                UpgradeRankInfo(current: "Max radius and impact", next: "Maximum radius and impact")
            ],
            medallionName: "upgrade-medallion-complement",
            accent: UIColor(red: 0.88, green: 0.43, blue: 1.0, alpha: 1.0)
        ),
        UpgradeDefinition(
            choice: .dash,
            term: "Chemotaxis",
            title: "Chemotaxis Dash",
            controls: "Use: Q, Shift + movement, or DASH button.",
            body: "Directional escape surge with brief contact protection, stronger movement, and faster recovery.",
            ranks: [
                UpgradeRankInfo(current: "Dash unlocked", next: "Unlock chemotaxis dash"),
                UpgradeRankInfo(current: "Faster surge, shorter recovery", next: "Faster surge, shorter recovery"),
                UpgradeRankInfo(current: "Longer slip protection", next: "Longer slip protection"),
                UpgradeRankInfo(current: "Max dash and invulnerable slip", next: "Maximum dash and invulnerable slip")
            ],
            medallionName: "upgrade-medallion-chemotaxis",
            accent: UIColor(red: 0.42, green: 1.0, blue: 0.66, alpha: 1.0)
        )
    ]
}

private struct SpriteFrame {
    let rect: CGRect
}

private struct AtlasFrames {
    private static let bossCandidateCell: CGFloat = 444

    private static func bossCandidateSheetFrames() -> [SpriteFrame] {
        (0..<8).map { index in
            let column = index % 4
            let row = index / 4
            return SpriteFrame(rect: CGRect(
                x: CGFloat(column) * bossCandidateCell,
                y: CGFloat(row) * bossCandidateCell,
                width: bossCandidateCell,
                height: bossCandidateCell
            ))
        }
    }

    static let whiteCell = [
        SpriteFrame(rect: CGRect(x: 45, y: 41, width: 184, height: 178)),
        SpriteFrame(rect: CGRect(x: 284, y: 58, width: 221, height: 158)),
        SpriteFrame(rect: CGRect(x: 590, y: 54, width: 224, height: 160)),
        SpriteFrame(rect: CGRect(x: 865, y: 56, width: 156, height: 158)),
        SpriteFrame(rect: CGRect(x: 1068, y: 64, width: 185, height: 150)),
        SpriteFrame(rect: CGRect(x: 1312, y: 90, width: 179, height: 131))
    ]

    static let greenVirus = [
        SpriteFrame(rect: CGRect(x: 132, y: 251, width: 198, height: 186)),
        SpriteFrame(rect: CGRect(x: 423, y: 252, width: 197, height: 182)),
        SpriteFrame(rect: CGRect(x: 705, y: 260, width: 185, height: 179)),
        SpriteFrame(rect: CGRect(x: 972, y: 265, width: 182, height: 181))
    ]

    static let purpleVirus = [
        SpriteFrame(rect: CGRect(x: 133, y: 465, width: 199, height: 189)),
        SpriteFrame(rect: CGRect(x: 435, y: 467, width: 196, height: 186)),
        SpriteFrame(rect: CGRect(x: 713, y: 471, width: 189, height: 182)),
        SpriteFrame(rect: CGRect(x: 980, y: 479, width: 191, height: 173))
    ]

    static let antibody = [
        SpriteFrame(rect: CGRect(x: 774, y: 892, width: 107, height: 62)),
        SpriteFrame(rect: CGRect(x: 947, y: 892, width: 123, height: 62)),
        SpriteFrame(rect: CGRect(x: 1125, y: 893, width: 139, height: 61)),
        SpriteFrame(rect: CGRect(x: 1316, y: 892, width: 143, height: 62))
    ]

    static let redCell = [
        SpriteFrame(rect: CGRect(x: 94, y: 674, width: 174, height: 132)),
        SpriteFrame(rect: CGRect(x: 357, y: 693, width: 185, height: 101)),
        SpriteFrame(rect: CGRect(x: 652, y: 698, width: 125, height: 96)),
        SpriteFrame(rect: CGRect(x: 916, y: 701, width: 90, height: 101))
    ]

    static let platelet = [
        SpriteFrame(rect: CGRect(x: 60, y: 843, width: 222, height: 134)),
        SpriteFrame(rect: CGRect(x: 349, y: 852, width: 145, height: 129)),
        SpriteFrame(rect: CGRect(x: 555, y: 862, width: 142, height: 108))
    ]

    static let influenza = [
        SpriteFrame(rect: CGRect(x: 117, y: 159, width: 396, height: 424)),
        SpriteFrame(rect: CGRect(x: 621, y: 129, width: 392, height: 452)),
        SpriteFrame(rect: CGRect(x: 1154, y: 173, width: 386, height: 407)),
        SpriteFrame(rect: CGRect(x: 1653, y: 180, width: 395, height: 395))
    ]

    static let poxBoss = [
        SpriteFrame(rect: CGRect(x: 0, y: 91, width: 543, height: 543)),
        SpriteFrame(rect: CGRect(x: 543, y: 91, width: 543, height: 543)),
        SpriteFrame(rect: CGRect(x: 1086, y: 91, width: 543, height: 543)),
        SpriteFrame(rect: CGRect(x: 1629, y: 91, width: 543, height: 543))
    ]

    static let adenovirus = [
        SpriteFrame(rect: CGRect(x: 0, y: 91, width: 543, height: 543)),
        SpriteFrame(rect: CGRect(x: 543, y: 91, width: 543, height: 543)),
        SpriteFrame(rect: CGRect(x: 1086, y: 91, width: 543, height: 543)),
        SpriteFrame(rect: CGRect(x: 1629, y: 91, width: 543, height: 543))
    ]

    static let filovirus = [
        SpriteFrame(rect: CGRect(x: 0, y: 91, width: 543, height: 543)),
        SpriteFrame(rect: CGRect(x: 543, y: 91, width: 543, height: 543)),
        SpriteFrame(rect: CGRect(x: 1086, y: 91, width: 543, height: 543)),
        SpriteFrame(rect: CGRect(x: 1629, y: 91, width: 543, height: 543))
    ]

    static let rotavirus = bossCandidateSheetFrames()
    static let lyssavirus = bossCandidateSheetFrames()
    static let norovirus = bossCandidateSheetFrames()
    static let norovirusDecoyOrb = SpriteFrame(rect: CGRect(x: 82, y: 74, width: 88, height: 88))

    static let startTitlePlaque = SpriteFrame(rect: CGRect(x: 132, y: 16, width: 1268, height: 372))
    static let startRunButton = SpriteFrame(rect: CGRect(x: 292, y: 414, width: 920, height: 190))
    static let startBestRunFrame = SpriteFrame(rect: CGRect(x: 408, y: 638, width: 720, height: 114))
    static let completePanel = SpriteFrame(rect: CGRect(x: 0, y: 28, width: 1088, height: 580))
    static let pausePanel = SpriteFrame(rect: CGRect(x: 1100, y: 48, width: 410, height: 592))
    static let buttonFrame = SpriteFrame(rect: CGRect(x: 70, y: 645, width: 868, height: 132))
}

private struct PlayerState {
    var position = CGPoint(x: 210, y: 360)
    var velocity = CGVector.zero
    var health = Constants.playerMaxHealth
    var shootCooldown: TimeInterval = 0
    var dashCooldown: TimeInterval = 0
    var dashTimer: TimeInterval = 0
    var pulseCooldown: TimeInterval = 0
    var invulnerable: TimeInterval = 0
    var hurtTimer: TimeInterval = 0
}

private final class ActivePulse {
    let origin: CGPoint
    let maxRadius: CGFloat
    let rank: Int
    let life: TimeInterval
    let visuals: [PulseVisual]
    var age: TimeInterval = 0
    var hitEnemyIds = Set<Int>()
    var hitPlateletIds = Set<ObjectIdentifier>()

    init(origin: CGPoint, maxRadius: CGFloat, rank: Int, life: TimeInterval, visuals: [PulseVisual]) {
        self.origin = origin
        self.maxRadius = maxRadius
        self.rank = rank
        self.life = life
        self.visuals = visuals
    }
}

private final class PulseVisual {
    let node: SKNode
    let scaleStart: CGFloat
    let scaleEnd: CGFloat
    let life: TimeInterval
    let fadePower: CGFloat

    init(node: SKNode, scaleStart: CGFloat, scaleEnd: CGFloat, life: TimeInterval, fadePower: CGFloat) {
        self.node = node
        self.scaleStart = scaleStart
        self.scaleEnd = scaleEnd
        self.life = life
        self.fadePower = fadePower
    }
}

private struct RunRecord {
    let score: Int
    let level: Int
    let sections: Int
    let neutralizations: Int
    let bosses: Int
    let survivalTime: TimeInterval
    let date: Date

    static let empty = RunRecord(score: 0, level: 1, sections: 0, neutralizations: 0, bosses: 0, survivalTime: 0, date: .distantPast)

    func isBetter(than other: RunRecord) -> Bool {
        if score != other.score {
            return score > other.score
        }
        if sections != other.sections {
            return sections > other.sections
        }
        if level != other.level {
            return level > other.level
        }
        if bosses != other.bosses {
            return bosses > other.bosses
        }
        if neutralizations != other.neutralizations {
            return neutralizations > other.neutralizations
        }
        return survivalTime > other.survivalTime
    }
}

private enum HapticCue {
    case selection
    case lightImpact
    case mediumImpact
    case heavyImpact
    case success
    case warning
}

private final class HapticEngine {
    private let selection = UISelectionFeedbackGenerator()
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private var muted = false

    func setMuted(_ value: Bool) {
        muted = value
        if !value {
            prepare()
        }
    }

    func prepare() {
        guard !muted else {
            return
        }
        selection.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
    }

    func play(_ cue: HapticCue) {
        guard !muted else {
            return
        }
        switch cue {
        case .selection:
            selection.selectionChanged()
            selection.prepare()
        case .lightImpact:
            lightImpact.impactOccurred()
            lightImpact.prepare()
        case .mediumImpact:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()
        case .heavyImpact:
            heavyImpact.impactOccurred()
            heavyImpact.prepare()
        case .success:
            notification.notificationOccurred(.success)
            notification.prepare()
        case .warning:
            notification.notificationOccurred(.warning)
            notification.prepare()
        }
    }
}

private final class GameCenterService {
    private(set) var isAuthenticated = false
    private var pendingRecord: RunRecord?
    var onAuthenticationChanged: ((Bool) -> Void)?

    func authenticate(presentingViewController: UIViewController?, bestRunProvider: @escaping () -> RunRecord?) {
        GKLocalPlayer.local.authenticateHandler = { [weak self, weak presentingViewController] viewController, error in
            guard let self else {
                return
            }

            if let viewController {
                presentingViewController?.present(viewController, animated: true)
                return
            }

            self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
            self.onAuthenticationChanged?(self.isAuthenticated)
            if self.isAuthenticated {
                if let bestRun = bestRunProvider() {
                    self.submit(record: bestRun)
                } else if let pendingRecord = self.pendingRecord {
                    self.submit(record: pendingRecord)
                }
            } else if error != nil {
                self.pendingRecord = bestRunProvider()
            }
        }
    }

    func submit(record: RunRecord) {
        guard record.score > 0 || record.level > 1 else {
            return
        }

        guard GKLocalPlayer.local.isAuthenticated else {
            pendingRecord = record
            return
        }

        let player = GKLocalPlayer.local
        if record.score > 0 {
            GKLeaderboard.submitScore(
                record.score,
                context: 0,
                player: player,
                leaderboardIDs: [Constants.scoreLeaderboardID]
            ) { _ in }
        }
        GKLeaderboard.submitScore(
            record.level,
            context: 0,
            player: player,
            leaderboardIDs: [Constants.levelLeaderboardID]
        ) { _ in }
    }

    @discardableResult
    func showLeaderboards(from presentingViewController: UIViewController?) -> Bool {
        guard GKLocalPlayer.local.isAuthenticated else {
            authenticate(presentingViewController: presentingViewController) {
                nil
            }
            return false
        }

        if let window = presentingViewController?.view.window {
            GKAccessPoint.shared.parentWindow = window
        }
        GKAccessPoint.shared.location = .topTrailing
        GKAccessPoint.shared.isActive = true
        GKAccessPoint.shared.trigger(state: .leaderboards) {
            GKAccessPoint.shared.isActive = false
        }
        return true
    }
}

private final class PlayerProfileStore {
    private enum Key {
        static let hasBestRun = "bloodstream.spritekit.profile.hasBestRun"
        static let bestScore = "bloodstream.spritekit.profile.bestScore"
        static let bestLevel = "bloodstream.spritekit.profile.bestLevel"
        static let bestSections = "bloodstream.spritekit.profile.bestSections"
        static let bestNeutralizations = "bloodstream.spritekit.profile.bestNeutralizations"
        static let bestBosses = "bloodstream.spritekit.profile.bestBosses"
        static let bestSurvivalTime = "bloodstream.spritekit.profile.bestSurvivalTime"
        static let bestDate = "bloodstream.spritekit.profile.bestDate"
        static let musicMuted = "bloodstream.spritekit.settings.musicMuted"
        static let sfxMuted = "bloodstream.spritekit.settings.sfxMuted"
        static let hapticsMuted = "bloodstream.spritekit.settings.hapticsMuted"
        static let tiltEnabled = "bloodstream.spritekit.settings.tiltEnabled"
        static let tiltSensitivity = "bloodstream.spritekit.settings.tiltSensitivity"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var hasBestRun: Bool {
        defaults.bool(forKey: Key.hasBestRun)
    }

    var bestRun: RunRecord {
        guard hasBestRun else {
            return .empty
        }
        return RunRecord(
            score: defaults.integer(forKey: Key.bestScore),
            level: max(1, defaults.integer(forKey: Key.bestLevel)),
            sections: defaults.integer(forKey: Key.bestSections),
            neutralizations: defaults.integer(forKey: Key.bestNeutralizations),
            bosses: defaults.integer(forKey: Key.bestBosses),
            survivalTime: defaults.double(forKey: Key.bestSurvivalTime),
            date: Date(timeIntervalSince1970: defaults.double(forKey: Key.bestDate))
        )
    }

    var musicMuted: Bool {
        get { defaults.bool(forKey: Key.musicMuted) }
        set { defaults.set(newValue, forKey: Key.musicMuted) }
    }

    var sfxMuted: Bool {
        get { defaults.bool(forKey: Key.sfxMuted) }
        set { defaults.set(newValue, forKey: Key.sfxMuted) }
    }

    var hapticsMuted: Bool {
        get { defaults.bool(forKey: Key.hapticsMuted) }
        set { defaults.set(newValue, forKey: Key.hapticsMuted) }
    }

    var tiltEnabled: Bool {
        get { defaults.bool(forKey: Key.tiltEnabled) }
        set { defaults.set(newValue, forKey: Key.tiltEnabled) }
    }

    var tiltSensitivity: CGFloat {
        get {
            let stored = defaults.double(forKey: Key.tiltSensitivity)
            guard stored > 0 else {
                return Constants.tiltSensitivityDefault
            }
            return clamp(CGFloat(stored), Constants.tiltSensitivityMin, Constants.tiltSensitivityMax)
        }
        set {
            defaults.set(Double(clamp(newValue, Constants.tiltSensitivityMin, Constants.tiltSensitivityMax)), forKey: Key.tiltSensitivity)
        }
    }

    @discardableResult
    func recordRun(_ record: RunRecord) -> Bool {
        guard !hasBestRun || record.isBetter(than: bestRun) else {
            return false
        }
        defaults.set(true, forKey: Key.hasBestRun)
        defaults.set(record.score, forKey: Key.bestScore)
        defaults.set(record.level, forKey: Key.bestLevel)
        defaults.set(record.sections, forKey: Key.bestSections)
        defaults.set(record.neutralizations, forKey: Key.bestNeutralizations)
        defaults.set(record.bosses, forKey: Key.bestBosses)
        defaults.set(record.survivalTime, forKey: Key.bestSurvivalTime)
        defaults.set(record.date.timeIntervalSince1970, forKey: Key.bestDate)
        return true
    }
}

private struct EnemyStats {
    let kind: EnemyKind
    let frames: [SpriteFrame]
    let texture: SKTexture
    let radius: CGFloat
    let hp: CGFloat
    let speed: CGFloat
    let score: Int
    let damage: CGFloat
    let reproductionCooldown: TimeInterval
}

private final class RedCell {
    let node: SKSpriteNode
    var position: CGPoint
    var radius: CGFloat
    var depth: CGFloat
    var speed: CGFloat
    var drift: CGFloat
    var rotation: CGFloat
    var spin: CGFloat
    var wobble: CGFloat
    var dead = false

    init(node: SKSpriteNode, position: CGPoint, radius: CGFloat, depth: CGFloat, speed: CGFloat, drift: CGFloat, rotation: CGFloat, spin: CGFloat, wobble: CGFloat) {
        self.node = node
        self.position = position
        self.radius = radius
        self.depth = depth
        self.speed = speed
        self.drift = drift
        self.rotation = rotation
        self.spin = spin
        self.wobble = wobble
    }
}

private final class Platelet {
    let node: SKSpriteNode
    var position: CGPoint
    var velocity: CGVector
    var radius: CGFloat
    var angle: CGFloat
    var spin: CGFloat
    var dead = false

    init(node: SKSpriteNode, position: CGPoint, velocity: CGVector, radius: CGFloat, angle: CGFloat, spin: CGFloat) {
        self.node = node
        self.position = position
        self.velocity = velocity
        self.radius = radius
        self.angle = angle
        self.spin = spin
    }
}

private final class Enemy {
    let id: Int
    let kind: EnemyKind
    let node: SKSpriteNode
    var position: CGPoint
    var velocity: CGVector
    var baseSpeed: CGFloat
    var radius: CGFloat
    var hp: CGFloat
    var maxHP: CGFloat
    var score: Int
    var damage: CGFloat
    var reproductionCooldown: TimeInterval
    var bossKind: BossKind?
    var damageScale: CGFloat
    var phase = 0
    var attackCooldown: TimeInterval = 0
    var shieldCycle: TimeInterval = 0
    var shieldOpen = false
    var bossActionTimer: TimeInterval = 0
    var bossTargetX: CGFloat = 0
    var bossTargetY: CGFloat = 0
    var orbitAngle: CGFloat = 0
    var orbitRadius: CGFloat = 0
    var orbitDirection: CGFloat = 1
    var bossComboStep = 0
    var bossTrailTimer: TimeInterval = 0
    var deathAnimationActive = false
    var dead = false

    init(
        id: Int,
        kind: EnemyKind,
        node: SKSpriteNode,
        position: CGPoint,
        velocity: CGVector,
        baseSpeed: CGFloat,
        radius: CGFloat,
        hp: CGFloat,
        score: Int,
        damage: CGFloat,
        reproductionCooldown: TimeInterval = 0,
        bossKind: BossKind? = nil,
        damageScale: CGFloat = 1,
        attackCooldown: TimeInterval = 0,
        shieldCycle: TimeInterval = 0
    ) {
        self.id = id
        self.kind = kind
        self.node = node
        self.position = position
        self.velocity = velocity
        self.baseSpeed = baseSpeed
        self.radius = radius
        self.hp = hp
        self.maxHP = hp
        self.score = score
        self.damage = damage
        self.reproductionCooldown = reproductionCooldown
        self.bossKind = bossKind
        self.damageScale = damageScale
        self.attackCooldown = attackCooldown
        self.shieldCycle = shieldCycle
    }
}

private final class Shot {
    let node: SKSpriteNode
    var position: CGPoint
    var velocity: CGVector
    var life: TimeInterval
    var damage: CGFloat
    var targetId: Int?
    var dead = false

    init(node: SKSpriteNode, position: CGPoint, velocity: CGVector, life: TimeInterval, damage: CGFloat, targetId: Int?) {
        self.node = node
        self.position = position
        self.velocity = velocity
        self.life = life
        self.damage = damage
        self.targetId = targetId
    }

    func reset(position: CGPoint, velocity: CGVector, life: TimeInterval, damage: CGFloat, targetId: Int?) {
        self.position = position
        self.velocity = velocity
        self.life = life
        self.damage = damage
        self.targetId = targetId
        self.dead = false
    }
}

private final class ParallaxLayer {
    let node = SKNode()
    let speed: CGFloat
    private let texture: SKTexture
    private let alpha: CGFloat
    private let tiles: [SKSpriteNode]
    private var layerScale: CGFloat = 1
    private var drawWidth: CGFloat = 1
    private var drawY: CGFloat = 0

    init(texture: SKTexture, speed: CGFloat, alpha: CGFloat, zPosition: CGFloat, tileCopies: Int = 4) {
        self.texture = texture
        self.speed = speed
        self.alpha = alpha
        self.tiles = (0..<tileCopies).map { _ in
            let sprite = SKSpriteNode(texture: texture)
            sprite.anchorPoint = .zero
            sprite.alpha = alpha
            sprite.zPosition = zPosition
            sprite.size = texture.size()
            return sprite
        }
        node.zPosition = zPosition
        tiles.forEach { node.addChild($0) }
    }

    func layout(in visibleSize: CGSize, scroll: CGFloat) {
        let textureSize = texture.size()
        guard textureSize.width > 0, textureSize.height > 0, visibleSize.width > 0, visibleSize.height > 0 else {
            return
        }

        layerScale = max(visibleSize.width / textureSize.width, visibleSize.height / textureSize.height)
        drawWidth = textureSize.width * layerScale
        let drawHeight = textureSize.height * layerScale
        drawY = (visibleSize.height - drawHeight) * 0.5
        update(scroll: scroll)
    }

    func update(scroll: CGFloat) {
        guard drawWidth > 0 else {
            return
        }

        let scrollPosition = scroll * speed
        let baseIndex = floor(scrollPosition / drawWidth)
        let localOffset = -(scrollPosition - baseIndex * drawWidth)
        let integerBaseIndex = Int(baseIndex)

        for (index, sprite) in tiles.enumerated() {
            let tile = index - 1
            let mirrored = (integerBaseIndex + tile) % 2 != 0
            let x = localOffset + CGFloat(tile) * drawWidth
            sprite.position = CGPoint(x: x + (mirrored ? drawWidth : 0), y: drawY)
            sprite.xScale = mirrored ? -layerScale : layerScale
            sprite.yScale = layerScale
        }
    }
}

final class GameScene: SKScene {
    private let stageNode = SKNode()
    private let backgroundNode = SKNode()
    private let entityNode = SKNode()
    private let projectileNode = SKNode()
    private let particleNode = SKNode()
    private let hudNode = SKNode()
    private let controlsNode = SKNode()
    private let overlayNode = SKNode()

    private let profileStore = PlayerProfileStore()
    private let audio = AudioSystem()
    private let haptics = HapticEngine()
    private let gameCenter = GameCenterService()
    private let motionManager = CMMotionManager()
    private var atlasTexture: SKTexture?
    private var influenzaTexture: SKTexture?
    private var poxBossTexture: SKTexture?
    private var adenovirusTexture: SKTexture?
    private var filovirusTexture: SKTexture?
    private var rotavirusTexture: SKTexture?
    private var lyssavirusTexture: SKTexture?
    private var norovirusTexture: SKTexture?
    private var startSheetTexture: SKTexture?
    private var titlePlaqueTexture: SKTexture?
    private var scoreFrameTexture: SKTexture?
    private var healthFrameTexture: SKTexture?
    private var scoreOrnamentTexture: SKTexture?
    private var healthOrnamentTexture: SKTexture?
    private var progressFrameTexture: SKTexture?
    private var levelFrameTexture: SKTexture?
    private var pauseFrameTexture: SKTexture?
    private var missionFrameTexture: SKTexture?
    private var pauseCompleteTexture: SKTexture?
    private var gameOverPanelTexture: SKTexture?
    private var howToPlayTexture: SKTexture?
    private var upgradeTitlePlaqueTexture: SKTexture?
    private var upgradeMedallionTextures: [UpgradeChoice: SKTexture] = [:]
    private var antibodyTextures: [SKTexture] = []
    private lazy var sparkTexture = GameScene.makeSparkTexture()
    private var backgroundLayers: [ParallaxLayer] = []

    private var mode: GameMode = .title
    private var stageScale: CGFloat = 1
    private var stageOrigin = CGPoint.zero
    private var lastUpdateTime: TimeInterval = 0
    private var sceneTime: TimeInterval = 0
    private var runTime: TimeInterval = 0
    private var scroll: CGFloat = 0
    private var screenShakeTimer: TimeInterval = 0
    private var screenShakeDuration: TimeInterval = 0
    private var screenShakeMagnitude: CGFloat = 0
    private var level = 1
    private var levelLength: CGFloat = 2720
    private var levelKills = 0
    private var levelGoal = 5
    private var activeMission = Constants.missions[0]
    private var score = 0
    private var sectionsCleared = 0
    private var totalKills = 0
    private var bossesNeutralized = 0
    private var nextEnemyId = 1
    private var spawnEnemyTimer: TimeInterval = 0.15
    private var spawnRedTimer: TimeInterval = 0.25
    private var spawnPlateletTimer: TimeInterval = 3.5
    private var levelClearTimer: TimeInterval = 0
    private var bossWarningTimer: TimeInterval = 0
    private var bossClearTimer: TimeInterval = 0
    private var bossWarningStarted = false
    private var bossSpawned = false
    private var bossDefeated = false
    private var bossTriggerProgress: CGFloat = 0.85
    private var shotSoundTimer: TimeInterval = 0
    private var bossHitFeedbackTimer: TimeInterval = 0
    private var plateletHitSoundTimer: TimeInterval = 0
    private var uiHoverSoundTimer: TimeInterval = 0
    private var pendingMusicCue: AudioCue?
    private var pendingMusicTimer: TimeInterval = 0
    private var dangerMusicActive = false
    private var musicMuted = false
    private var sfxMuted = false
    private var hapticsMuted = false
    private var lastRunWasBest = false
    private var restartConfirmVisible = false
    private var audioSettingsVisible = false
    private var inputSettingsVisible = false
    private var howToPlayVisible = false
    private var rapidRank = 0
    private var pulseRank = 0
    private var dashRank = 0
    private var dashInputHeld = false
    private var horizontalSwimSoundInput = 0
    private var dashTrailTimer: TimeInterval = 0
    private var swimWakeTimer: TimeInterval = 0
    private var lastFacing = CGVector(dx: 1, dy: 0)
    private var tiltEnabled = false
    private var tiltHasCalibration = false
    private var tiltNeutral = CGVector.zero
    private var tiltVector = CGVector.zero
    private var tiltSensitivity = Constants.tiltSensitivityDefault
    private var player = PlayerState()
    private var enemies: [Enemy] = []
    private var redCells: [RedCell] = []
    private var platelets: [Platelet] = []
    private var shots: [Shot] = []
    private var shotPool: [Shot] = []
    private var sparkPool: [SKSpriteNode] = []
    private var activePulses: [ActivePulse] = []
    private var cosmeticNodesSpawnedThisFrame = 0
    private var hitFlashesThisFrame = 0
    private var pressedKeys = Set<UIKeyboardHIDUsage>()
    private var joystickTouchId: ObjectIdentifier?
    private var tiltSensitivityTouchId: ObjectIdentifier?
    private var fireTouchIds = Set<ObjectIdentifier>()
    private var joystickVector = CGVector.zero
    private var lockTargetId: Int?

    private var playerNode: SKSpriteNode?
    private var scoreLabel: SKLabelNode?
    private var missionLabel: SKLabelNode?
    private var levelLabel: SKLabelNode?
    private var targetLabel: SKLabelNode?
    private var bannerLabel: SKLabelNode?
    private var healthFill: SKShapeNode?
    private var titleGroup = SKNode()
    private var startButton = SKShapeNode()
    private var titleHowToPlayButton = SKShapeNode()
    private var leaderboardsButton = SKShapeNode()
    private var leaderboardsLabel: SKLabelNode?
    private var bestRunLabel: SKLabelNode?
    private var pauseOverlay = SKNode()
    private var upgradeOverlay = SKNode()
    private var gameOverOverlay = SKNode()
    private var pauseButton = SKShapeNode()
    private var resumeButton = SKShapeNode()
    private var restartButton = SKShapeNode()
    private var audioSettingsButton = SKShapeNode()
    private var musicToggleButton = SKShapeNode()
    private var sfxToggleButton = SKShapeNode()
    private var hapticsToggleButton = SKShapeNode()
    private var inputSettingsButton = SKShapeNode()
    private var howToPlayButton = SKShapeNode()
    private var tiltToggleButton = SKShapeNode()
    private var tiltCalibrateButton = SKShapeNode()
    private var audioSettingsLabel: SKLabelNode?
    private var musicToggleLabel: SKLabelNode?
    private var sfxToggleLabel: SKLabelNode?
    private var hapticsToggleLabel: SKLabelNode?
    private var inputSettingsLabel: SKLabelNode?
    private var howToPlayLabel: SKLabelNode?
    private var tiltToggleLabel: SKLabelNode?
    private var tiltCalibrateLabel: SKLabelNode?
    private var audioSettingsOverlay = SKNode()
    private var audioSettingsBackButton = SKShapeNode()
    private var inputSettingsOverlay = SKNode()
    private var inputSettingsBackButton = SKShapeNode()
    private var howToPlayOverlay = SKNode()
    private var howToPlayBackButton = SKShapeNode()
    private var tiltSensitivityTrack = SKShapeNode()
    private var tiltSensitivityFill = SKShapeNode()
    private var tiltSensitivityKnob = SKShapeNode()
    private var tiltSensitivityHitArea = SKShapeNode()
    private var tiltSensitivityLabel: SKLabelNode?
    private var tiltCalibrationToast = SKNode()
    private var tiltCalibrationToastFrame: SKShapeNode?
    private var tiltCalibrationToastLabel: SKLabelNode?
    private var restartConfirmOverlay = SKNode()
    private var restartConfirmButton = SKShapeNode()
    private var restartCancelButton = SKShapeNode()
    private var levelCompleteOverlay = SKNode()
    private var levelCompleteTitleLabel: SKLabelNode?
    private var levelCompleteBodyLabel: SKLabelNode?
    private var levelCompleteActionButton = SKShapeNode()
    private var levelCompleteActionLabel: SKLabelNode?
    private var upgradeButtons: [SKShapeNode: UpgradeChoice] = [:]
    private var upgradeRankLabels: [UpgradeChoice: SKLabelNode] = [:]
    private var upgradeNextRankLabels: [UpgradeChoice: SKLabelNode] = [:]
    private var upgradeButtonLabels: [UpgradeChoice: SKLabelNode] = [:]
    private var upgradePips: [UpgradeChoice: [SKShapeNode]] = [:]
    private var upgradeIntroLabel: SKLabelNode?
    private var gameOverSubtitleLabel: SKLabelNode?
    private var gameOverRecordLabel: SKLabelNode?
    private var gameOverStatLabels: [String: SKLabelNode] = [:]
    private var gameOverAdaptationsLabel: SKLabelNode?
    private var tryAgainButton = SKShapeNode()
    private var progressFill: SKShapeNode?
    private var joystickRing = SKShapeNode()
    private var joystickKnob = SKShapeNode()
    private var dashButton = SKShapeNode()
    private var pulseButton = SKShapeNode()
    private var dashLabel: SKLabelNode?
    private var pulseLabel: SKLabelNode?

    deinit {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        anchorPoint = .zero
        startMotionInputIfNeeded()
        loadTextures()
        setupStage()
        setupBackground()
        setupPlayer()
        setupHUD()
        setupControls()
        setupOverlays()
        applySavedProfileSettings()
        configureGameCenter()
        showTitle()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        relayoutStage()
    }

    func setKey(_ keyCode: UIKeyboardHIDUsage, isPressed: Bool) {
        if isPressed {
            pressedKeys.insert(keyCode)
#if DEBUG
            if keyCode == .keyboardU, mode == .running {
                showUpgradeSelection()
                return
            }
            if keyCode == .keyboardN, mode == .running {
                startNextLevel()
                return
            }
            if keyCode == .keyboardB, mode == .running {
                if activeMission.bossKind == nil {
                    loadLevel(max(5, level), clearEntities: true)
                }
                bossTriggerProgress = 0
                bossWarningStarted = true
                bossWarningTimer = 0.8
                bossClearTimer = 0.25
                bossSpawned = false
                bossDefeated = false
                player.health = Constants.playerMaxHealth
                player.invulnerable = 30.0
                player.position = CGPoint(x: 210, y: 360)
                player.velocity = .zero
                playerNode?.position = baseToStage(player.position)
                showBanner("Debug boss signal")
                return
            }
            if keyCode == .keyboardL, mode == .running {
                levelKills = max(levelKills, levelGoal)
                finishLevel(delay: 0.1)
                return
            }
            if keyCode == .keyboardG, mode == .running || mode == .paused || mode == .levelComplete || mode == .upgrade {
                endRun()
                return
            }
#endif
            if keyCode == .keyboardSpacebar {
                fireAntibody(force: true)
            } else if keyCode == .keyboardP {
                togglePause()
            } else if keyCode == .keyboardQ {
                triggerDash(input: currentMovementVector())
            } else if keyCode == .keyboardE || keyCode == .keyboardReturnOrEnter {
                triggerPulse()
            } else if keyCode == .keyboardR, mode == .paused || mode == .gameOver || mode == .upgrade || mode == .levelComplete {
                startRun()
            }
        } else {
            pressedKeys.remove(keyCode)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let delta: TimeInterval
        if lastUpdateTime == 0 {
            delta = 1.0 / 60.0
        } else {
            delta = min(currentTime - lastUpdateTime, 1.0 / 30.0)
        }
        lastUpdateTime = currentTime
        sceneTime += delta
        cosmeticNodesSpawnedThisFrame = 0
        hitFlashesThisFrame = 0

        switch mode {
        case .title:
            scroll += CGFloat(delta) * 70
            updateBackground()
        case .running:
            runTime += delta
            scroll += CGFloat(delta) * 185
            updateBackground()
            updatePlayer(delta: delta)
            updateSpawning(delta: delta)
            updateShots(delta: delta)
            updateEnemies(delta: delta)
            updateProps(delta: delta)
            updateActivePulses(delta: delta)
            updateCollisions()
            updateLevelFlow(delta: delta)
            updateHUD()
        case .levelComplete:
            updateBackground()
        case .upgrade:
            updateBackground()
            updateUpgradePipPulse()
        case .paused, .gameOver:
            break
        }

        shotSoundTimer = max(0, shotSoundTimer - delta)
        bossHitFeedbackTimer = max(0, bossHitFeedbackTimer - delta)
        plateletHitSoundTimer = max(0, plateletHitSoundTimer - delta)
        uiHoverSoundTimer = max(0, uiHoverSoundTimer - delta)
        updateScreenShake(delta: delta)
        updateAudio(delta: delta)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let basePoint = scenePointToBase(touch.location(in: self))
            let touchId = ObjectIdentifier(touch)

            if mode == .title {
                let stagePoint = baseToStage(basePoint)
                if howToPlayVisible {
                    if howToPlayBackButton.contains(stagePoint) {
                        playUITap()
                        closeHowToPlay()
                    }
                    continue
                }
                if startButton.contains(stagePoint) {
                    playUITap()
                    startRun()
                    continue
                }
                if titleHowToPlayButton.contains(stagePoint) {
                    playUITap()
                    openHowToPlay()
                    continue
                }
                if leaderboardsButton.contains(stagePoint) {
                    playUITap()
                    if !gameCenter.showLeaderboards(from: presentingViewController()) {
                        showBanner("Sign into Game Center")
                    }
                    continue
                }
            }

            if mode == .gameOver, tryAgainButton.contains(baseToStage(basePoint)) {
                playUITap()
                startRun()
                continue
            }

            if mode == .paused {
                let stagePoint = baseToStage(basePoint)
                if audioSettingsVisible {
                    if audioSettingsBackButton.contains(stagePoint) {
                        playUITap()
                        closeAudioSettings()
                    } else if musicToggleButton.contains(stagePoint) {
                        setMusicMuted(!musicMuted)
                        playUITap()
                    } else if sfxToggleButton.contains(stagePoint) {
                        setSFXMuted(!sfxMuted)
                        playUITap()
                    } else if hapticsToggleButton.contains(stagePoint) {
                        setHapticsMuted(!hapticsMuted)
                        audio.playSFX(.uiSelect)
                        haptics.play(.selection)
                    }
                } else if inputSettingsVisible {
                    if inputSettingsBackButton.contains(stagePoint) {
                        playUITap()
                        closeInputSettings()
                    } else if tiltToggleButton.contains(stagePoint) {
                        toggleTiltMode()
                        playUITap()
                    } else if tiltCalibrateButton.contains(stagePoint) {
                        let calibrated = calibrateTilt(showBannerText: false)
                        showTiltCalibrationFeedback(success: calibrated)
                        playUITap()
                    } else if tiltSensitivityHitArea.contains(stagePoint) {
                        tiltSensitivityTouchId = touchId
                        setTiltSensitivity(fromBaseX: basePoint.x)
                        haptics.play(.selection)
                    }
                } else if howToPlayVisible {
                    if howToPlayBackButton.contains(stagePoint) {
                        playUITap()
                        closeHowToPlay()
                    }
                } else if restartConfirmVisible {
                    if restartConfirmButton.contains(stagePoint) {
                        playUITap()
                        startRun()
                    } else if restartCancelButton.contains(stagePoint) {
                        playPauseResumeSFX()
                        haptics.play(.selection)
                        restartConfirmVisible = false
                        restartConfirmOverlay.isHidden = true
                    }
                } else if resumeButton.contains(stagePoint) {
                    playPauseResumeSFX()
                    haptics.play(.selection)
                    togglePause()
                } else if restartButton.contains(stagePoint) {
                    audio.playSFX(.restartConfirm)
                    haptics.play(.mediumImpact)
                    closePauseSubmenus()
                    restartConfirmVisible = true
                    restartConfirmOverlay.isHidden = false
                } else if audioSettingsButton.contains(stagePoint) {
                    playUITap()
                    openAudioSettings()
                } else if inputSettingsButton.contains(stagePoint) {
                    playUITap()
                    openInputSettings()
                } else if howToPlayButton.contains(stagePoint) {
                    playUITap()
                    openHowToPlay()
                }
                continue
            }

            if mode == .levelComplete {
                let stagePoint = baseToStage(basePoint)
                if levelCompleteActionButton.contains(stagePoint) {
                    playUITap()
                    openUpgradeScreenOrContinue()
                }
                continue
            }

            if mode == .upgrade {
                let stagePoint = baseToStage(basePoint)
                if allUpgradesComplete() {
                    playUITap()
                    startNextLevel()
                    continue
                }
                if let choice = upgradeButtons.first(where: { $0.key.contains(stagePoint) })?.value {
                    selectUpgrade(choice)
                }
                continue
            }

            guard mode == .running else {
                continue
            }

            let stagePoint = baseToStage(basePoint)
            if pauseButton.contains(stagePoint) {
                togglePause()
            } else if !tiltEnabled && distance(basePoint, Constants.joystickCenter) <= Constants.joystickTouchRadius {
                joystickTouchId = touchId
                updateJoystick(with: basePoint)
            } else if dashButton.contains(stagePoint) {
                triggerDash(input: currentMovementVector())
            } else if pulseButton.contains(stagePoint) {
                triggerPulse()
            } else {
                fireTouchIds.insert(touchId)
                fireAntibody(force: true)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchId = ObjectIdentifier(touch)
            let basePoint = scenePointToBase(touch.location(in: self))
            if touchId == tiltSensitivityTouchId {
                setTiltSensitivity(fromBaseX: basePoint.x)
            } else if touchId == joystickTouchId {
                updateJoystick(with: basePoint)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouches(touches)
    }

    private func setupStage() {
        addChild(backgroundNode)
        addChild(stageNode)
        stageNode.addChild(entityNode)
        stageNode.addChild(projectileNode)
        stageNode.addChild(particleNode)
        stageNode.addChild(hudNode)
        stageNode.addChild(controlsNode)
        stageNode.addChild(overlayNode)
        backgroundNode.zPosition = -100
        stageNode.zPosition = 0
        entityNode.zPosition = ZLayer.entity
        projectileNode.zPosition = ZLayer.projectile
        particleNode.zPosition = ZLayer.particles
        hudNode.zPosition = ZLayer.hud
        controlsNode.zPosition = ZLayer.controls
        overlayNode.zPosition = ZLayer.overlay
        relayoutStage()
    }

    private func relayoutStage() {
        guard size.width > 0, size.height > 0 else {
            return
        }
        let scaleX = size.width / Constants.baseSize.width
        let scaleY = size.height / Constants.baseSize.height
        stageScale = min(scaleX, scaleY)
        stageOrigin = CGPoint(
            x: max(0, (size.width - Constants.baseSize.width * stageScale) * 0.5),
            y: max(0, (size.height - Constants.baseSize.height * stageScale) * 0.5)
        )
        stageNode.position = stageOrigin
        stageNode.setScale(stageScale)
        layoutBackground()
        updateOverlayShadeFrames()
    }

    private func loadTextures() {
        atlasTexture = texture(named: "bloodstream-asset-atlas-transparent-no-despill", extension: "png", subdirectory: "Assets/sprites/processed")
        if let atlasTexture {
            antibodyTextures = AtlasFrames.antibody.map { regionTexture(from: atlasTexture, frame: $0) }
        }
        influenzaTexture = texture(named: "influenza-virion-spritesheet", extension: "png", subdirectory: "Assets/sprites/processed")
        poxBossTexture = texture(named: "pox-brick-boss-spritesheet", extension: "png", subdirectory: "Assets/sprites/processed")
        adenovirusTexture = texture(named: "adenovirus-prism-spritesheet", extension: "png", subdirectory: "Assets/sprites/processed")
        filovirusTexture = texture(named: "filovirus-ribbon-spritesheet", extension: "png", subdirectory: "Assets/sprites/processed")
        rotavirusTexture = texture(named: "rotavirus-gyre-spritesheet", extension: "png", subdirectory: "Assets/sprites/processed")
        lyssavirusTexture = texture(named: "lyssavirus-lance-spritesheet", extension: "png", subdirectory: "Assets/sprites/processed")
        norovirusTexture = texture(named: "norovirus-swarm-core-spritesheet", extension: "png", subdirectory: "Assets/sprites/processed")
        startSheetTexture = texture(named: "start-screen-asset-sheet", extension: "png", subdirectory: "Assets/ui")
        titlePlaqueTexture = texture(named: "start-title-plaque", extension: "png", subdirectory: "Assets/ui")
        scoreFrameTexture = texture(named: "hud-game-score-frame", extension: "png", subdirectory: "Assets/ui")
        healthFrameTexture = texture(named: "hud-game-health-frame", extension: "png", subdirectory: "Assets/ui")
        scoreOrnamentTexture = texture(named: "hud-orn-score", extension: "png", subdirectory: "Assets/ui")
        healthOrnamentTexture = texture(named: "hud-orn-health", extension: "png", subdirectory: "Assets/ui")
        progressFrameTexture = texture(named: "hud-game-progress-frame-simple-imagegen", extension: "png", subdirectory: "Assets/ui")
        levelFrameTexture = texture(named: "hud-game-level-frame", extension: "png", subdirectory: "Assets/ui")
        pauseFrameTexture = texture(named: "hud-game-pause-frame", extension: "png", subdirectory: "Assets/ui")
        missionFrameTexture = texture(named: "hud-mission-frame", extension: "png", subdirectory: "Assets/ui")
        pauseCompleteTexture = texture(named: "pause-complete-ui-sheet", extension: "png", subdirectory: "Assets/ui")
        gameOverPanelTexture = texture(named: "game-over-summary-panel", extension: "png", subdirectory: "Assets/ui")
        howToPlayTexture = texture(named: "how-to-play-illustrated-v2-controls", extension: "png", subdirectory: "Assets/ui")
        upgradeTitlePlaqueTexture = texture(named: "upgrade-title-plaque-clean", extension: "png", subdirectory: "Assets/ui")
        upgradeMedallionTextures.removeAll()
        for definition in Constants.upgrades {
            upgradeMedallionTextures[definition.choice] = texture(named: definition.medallionName, extension: "png", subdirectory: "Assets/ui")
        }
    }

    private func setupBackground() {
        backgroundNode.removeAllChildren()
        backgroundLayers.removeAll()

        for (index, definition) in Constants.parallaxLayers.enumerated() {
            guard let layerTexture = texture(named: definition.name, extension: "png", subdirectory: definition.subdirectory) else {
                continue
            }
            let layer = ParallaxLayer(
                texture: layerTexture,
                speed: definition.speed,
                alpha: definition.alpha,
                zPosition: CGFloat(index)
            )
            backgroundNode.addChild(layer.node)
            backgroundLayers.append(layer)
        }

        layoutBackground()
    }

    private func updateBackground() {
        backgroundLayers.forEach { $0.update(scroll: scroll) }
    }

    private func layoutBackground() {
        backgroundLayers.forEach { $0.layout(in: size, scroll: scroll) }
    }

    private func setupPlayer() {
        guard let atlasTexture else {
            return
        }
        let frame = AtlasFrames.whiteCell[0]
        let texture = regionTexture(from: atlasTexture, frame: frame)
        let node = SKSpriteNode(texture: texture)
        node.size = playerSpriteSize(for: frame)
        node.zPosition = ZLayer.entity + 6
        node.position = baseToStage(player.position)
        entityNode.addChild(node)
        playerNode = node
    }

    private func setupHUD() {
        hudNode.removeAllChildren()

        if let scoreFrameTexture {
            let frame = SKSpriteNode(texture: scoreFrameTexture)
            frame.anchorPoint = CGPoint(x: 0, y: 1)
            frame.position = baseToStage(CGPoint(x: 22, y: 12))
            frame.size = CGSize(width: 210, height: 84)
            hudNode.addChild(frame)
        }

        if let scoreOrnamentTexture {
            let ornament = SKSpriteNode(texture: scoreOrnamentTexture)
            ornament.position = baseToStage(CGPoint(x: 65, y: 54))
            ornament.size = CGSize(width: 54, height: 54)
            ornament.zPosition = ZLayer.hud + 1
            hudNode.addChild(ornament)
        }

        let scoreTitle = label("SCORE", size: 11, color: UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 1.0))
        scoreTitle.horizontalAlignmentMode = .left
        scoreTitle.position = baseToStage(CGPoint(x: 104, y: 38))
        hudNode.addChild(scoreTitle)

        let scoreValue = label("0", size: 24, color: UIColor(red: 1.0, green: 0.96, blue: 0.78, alpha: 1.0))
        scoreValue.horizontalAlignmentMode = .left
        scoreValue.position = baseToStage(CGPoint(x: 104, y: 64))
        hudNode.addChild(scoreValue)
        scoreLabel = scoreValue

        if let healthFrameTexture {
            let frame = SKSpriteNode(texture: healthFrameTexture)
            frame.anchorPoint = CGPoint(x: 0, y: 1)
            frame.position = baseToStage(CGPoint(x: 250, y: 12))
            frame.size = CGSize(width: 450, height: 84)
            hudNode.addChild(frame)
        }

        if let healthOrnamentTexture {
            let ornament = SKSpriteNode(texture: healthOrnamentTexture)
            ornament.position = baseToStage(CGPoint(x: 291, y: 54))
            ornament.size = CGSize(width: 54, height: 54)
            ornament.zPosition = ZLayer.hud + 1
            hudNode.addChild(ornament)
        }

        let healthBack = SKShapeNode(rectOf: Constants.healthBarSize, cornerRadius: 10)
        healthBack.fillColor = UIColor(red: 0.02, green: 0.0, blue: 0.03, alpha: 0.82)
        healthBack.strokeColor = .clear
        healthBack.lineWidth = 0
        healthBack.zPosition = ZLayer.hud + 2
        healthBack.position = baseToStage(Constants.healthBarCenter)
        hudNode.addChild(healthBack)

        let healthFill = SKShapeNode(
            rect: CGRect(
                x: 0,
                y: -Constants.healthBarSize.height * 0.5,
                width: Constants.healthBarSize.width,
                height: Constants.healthBarSize.height
            ),
            cornerRadius: 10
        )
        healthFill.fillColor = UIColor(red: 0.42, green: 1.0, blue: 0.84, alpha: 1.0)
        healthFill.strokeColor = .clear
        healthFill.zPosition = ZLayer.hud + 3
        healthFill.position = baseToStage(CGPoint(
            x: Constants.healthBarCenter.x - Constants.healthBarSize.width * 0.5,
            y: Constants.healthBarCenter.y
        ))
        hudNode.addChild(healthFill)
        self.healthFill = healthFill

        let mission = label("Innate Patrol", size: 22, color: UIColor(red: 1.0, green: 0.87, blue: 0.42, alpha: 1.0))
        mission.position = baseToStage(CGPoint(x: 640, y: 108))
        hudNode.addChild(mission)
        missionLabel = mission

        let target = label("5 virions left", size: 18, color: UIColor(red: 0.80, green: 1.0, blue: 1.0, alpha: 1.0))
        target.position = baseToStage(CGPoint(x: 640, y: 134))
        hudNode.addChild(target)
        targetLabel = target

        if let progressFrameTexture {
            let frame = SKSpriteNode(texture: progressFrameTexture)
            frame.position = baseToStage(Constants.progressBarCenter)
            frame.size = Constants.progressFrameSize
            frame.zPosition = ZLayer.hud + 1
            hudNode.addChild(frame)
        }

        let progressCornerRadius = Constants.progressBarSize.height * 0.5
        let progressBack = SKShapeNode(rectOf: Constants.progressBarSize, cornerRadius: progressCornerRadius)
        progressBack.fillColor = UIColor(red: 0.01, green: 0.0, blue: 0.02, alpha: 0.66)
        progressBack.strokeColor = .clear
        progressBack.zPosition = ZLayer.hud + 2
        progressBack.position = baseToStage(Constants.progressBarCenter)
        hudNode.addChild(progressBack)

        let progressFill = SKShapeNode(
            rect: CGRect(
                x: 0,
                y: -Constants.progressBarSize.height * 0.5,
                width: Constants.progressBarSize.width,
                height: Constants.progressBarSize.height
            ),
            cornerRadius: progressCornerRadius
        )
        progressFill.fillColor = UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 0.94)
        progressFill.strokeColor = .clear
        progressFill.zPosition = ZLayer.hud + 3
        progressFill.position = baseToStage(CGPoint(
            x: Constants.progressBarCenter.x - Constants.progressBarSize.width * 0.5,
            y: Constants.progressBarCenter.y
        ))
        hudNode.addChild(progressFill)
        self.progressFill = progressFill

        let banner = label("", size: 24, color: UIColor(red: 1.0, green: 0.82, blue: 0.32, alpha: 1.0))
        banner.position = baseToStage(CGPoint(x: 640, y: 196))
        banner.alpha = 0
        banner.zPosition = ZLayer.overlay + 72
        overlayNode.addChild(banner)
        bannerLabel = banner

        if let levelFrameTexture {
            let frame = SKSpriteNode(texture: levelFrameTexture)
            frame.anchorPoint = CGPoint(x: 1, y: 1)
            frame.position = baseToStage(CGPoint(x: 1260, y: 12))
            frame.size = CGSize(width: 78, height: 76)
            frame.zPosition = ZLayer.hud + 1
            hudNode.addChild(frame)
        }

        let levelTitle = label("LEVEL", size: 9, color: UIColor(red: 1.0, green: 0.86, blue: 0.42, alpha: 1.0))
        levelTitle.position = baseToStage(CGPoint(x: 1221, y: 33))
        hudNode.addChild(levelTitle)

        let level = label("1", size: 24, color: UIColor(red: 1.0, green: 0.96, blue: 0.78, alpha: 1.0))
        level.position = baseToStage(CGPoint(x: 1221, y: 58))
        hudNode.addChild(level)
        levelLabel = level

        if let pauseFrameTexture {
            let frame = SKSpriteNode(texture: pauseFrameTexture)
            frame.position = baseToStage(CGPoint(x: 1115, y: 43))
            frame.size = CGSize(width: 112, height: 66)
            frame.zPosition = ZLayer.hud + 1
            hudNode.addChild(frame)
        }

        pauseButton = SKShapeNode(rectOf: CGSize(width: 112, height: 66), cornerRadius: 12)
        pauseButton.fillColor = .clear
        pauseButton.strokeColor = .clear
        pauseButton.lineWidth = 0
        pauseButton.position = baseToStage(CGPoint(x: 1115, y: 43))
        pauseButton.zPosition = ZLayer.hud + 2
        hudNode.addChild(pauseButton)

        let pauseLabel = label("PAUSE", size: 15, color: UIColor(red: 0.86, green: 1.0, blue: 1.0, alpha: 1.0))
        pauseLabel.position = baseToStage(CGPoint(x: 1115, y: 43))
        hudNode.addChild(pauseLabel)
    }

    private func setupControls() {
        controlsNode.removeAllChildren()

        joystickRing = SKShapeNode(circleOfRadius: Constants.joystickRadius)
        joystickRing.fillColor = UIColor(red: 0.78, green: 1.0, blue: 1.0, alpha: 0.12)
        joystickRing.strokeColor = UIColor(red: 0.90, green: 1.0, blue: 1.0, alpha: 0.70)
        joystickRing.lineWidth = 2.5
        joystickRing.glowWidth = 4
        joystickRing.position = baseToStage(Constants.joystickCenter)
        controlsNode.addChild(joystickRing)
        addJoystickGlassDetails()

        joystickKnob = SKShapeNode(circleOfRadius: Constants.joystickKnobRadius)
        joystickKnob.fillColor = UIColor(red: 0.96, green: 1.0, blue: 1.0, alpha: 0.24)
        joystickKnob.strokeColor = UIColor(red: 1.0, green: 0.90, blue: 0.46, alpha: 0.88)
        joystickKnob.lineWidth = 2
        joystickKnob.glowWidth = 3
        joystickKnob.position = joystickRing.position
        controlsNode.addChild(joystickKnob)
        addJoystickKnobGlassDetails()

        let abilityButtonSize = CGSize(width: 188, height: 86)
        let abilityCornerRadius: CGFloat = 24

        dashButton = SKShapeNode(rectOf: abilityButtonSize, cornerRadius: abilityCornerRadius)
        dashButton.fillColor = UIColor(red: 0.70, green: 1.0, blue: 1.0, alpha: 0.14)
        dashButton.strokeColor = UIColor(red: 0.86, green: 1.0, blue: 1.0, alpha: 0.42)
        dashButton.lineWidth = 2.5
        dashButton.glowWidth = 3
        dashButton.position = baseToStage(CGPoint(x: 1118, y: 535))
        dashButton.zPosition = ZLayer.controls + 20
        controlsNode.addChild(dashButton)

        let dashLabel = label("LOCKED", size: 18, color: UIColor(red: 0.70, green: 0.86, blue: 0.88, alpha: 0.86))
        dashLabel.position = dashButton.position
        dashLabel.zPosition = ZLayer.controls + 21
        controlsNode.addChild(dashLabel)
        self.dashLabel = dashLabel

        pulseButton = SKShapeNode(rectOf: abilityButtonSize, cornerRadius: abilityCornerRadius)
        pulseButton.fillColor = UIColor(red: 0.70, green: 1.0, blue: 1.0, alpha: 0.14)
        pulseButton.strokeColor = UIColor(red: 0.86, green: 1.0, blue: 1.0, alpha: 0.42)
        pulseButton.lineWidth = 2.5
        pulseButton.glowWidth = 3
        pulseButton.position = baseToStage(CGPoint(x: 1118, y: 633))
        pulseButton.zPosition = ZLayer.controls + 22
        controlsNode.addChild(pulseButton)

        let pulseLabel = label("LOCKED", size: 18, color: UIColor(red: 0.70, green: 0.86, blue: 0.88, alpha: 0.86))
        pulseLabel.position = pulseButton.position
        pulseLabel.zPosition = ZLayer.controls + 23
        controlsNode.addChild(pulseLabel)
        self.pulseLabel = pulseLabel

        controlsNode.isHidden = true
    }

    private func addJoystickGlassDetails() {
        for index in 0..<2 {
            let ring = SKShapeNode(circleOfRadius: Constants.joystickRadius - 18 - CGFloat(index) * 22)
            ring.fillColor = .clear
            ring.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: index == 0 ? 0.22 : 0.12)
            ring.lineWidth = 1
            ring.zPosition = 1
            joystickRing.addChild(ring)
        }

        for angleIndex in 0..<4 {
            let angle = CGFloat(angleIndex) * .pi * 0.5
            let inner = Constants.joystickRadius - 18
            let outer = Constants.joystickRadius - 7
            let tick = glassLine(
                points: [
                    CGPoint(x: cos(angle) * inner, y: sin(angle) * inner),
                    CGPoint(x: cos(angle) * outer, y: sin(angle) * outer)
                ],
                color: UIColor(red: 1.0, green: 0.90, blue: 0.46, alpha: 0.50),
                width: 2
            )
            tick.glowWidth = 2
            tick.zPosition = 2
            joystickRing.addChild(tick)
        }
    }

    private func addJoystickKnobGlassDetails() {
        let shine = SKShapeNode(circleOfRadius: Constants.joystickKnobRadius * 0.38)
        shine.fillColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.28)
        shine.strokeColor = .clear
        shine.position = CGPoint(x: -7, y: 8)
        shine.zPosition = 1
        joystickKnob.addChild(shine)

        let core = SKShapeNode(circleOfRadius: Constants.joystickKnobRadius * 0.18)
        core.fillColor = UIColor(red: 1.0, green: 0.86, blue: 0.34, alpha: 0.58)
        core.strokeColor = UIColor(red: 1.0, green: 1.0, blue: 0.82, alpha: 0.40)
        core.lineWidth = 1
        core.glowWidth = 3
        core.zPosition = 2
        joystickKnob.addChild(core)
    }

    private func glassLine(points: [CGPoint], color: UIColor, width: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        guard let first = points.first else {
            return SKShapeNode()
        }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        let line = SKShapeNode(path: path)
        line.fillColor = .clear
        line.strokeColor = color
        line.lineWidth = width
        line.lineCap = .round
        line.lineJoin = .round
        return line
    }

    private func setupOverlays() {
        setupTitleOverlay()
        setupPauseOverlay()
        setupLevelCompleteOverlay()
        setupUpgradeOverlay()
        setupGameOverOverlay()
    }

    private func setupTitleOverlay() {
        titleGroup.removeAllChildren()
        titleGroup.addChild(overlayShade(alpha: 0.42))

        let centerX = Constants.baseSize.width * 0.5
        let titleCenterX = centerX - 1
        let bestRunCenterX = centerX + 25
        let startCenterX = centerX - 3
        let titleY: CGFloat = 198
        let bestRunY: CGFloat = 404
        let startY: CGFloat = 548
        let howToPlayY: CGFloat = 616
        let gameCenterY: CGFloat = 680

        if let startSheetTexture {
            let plaque = SKSpriteNode(texture: regionTexture(from: startSheetTexture, frame: AtlasFrames.startTitlePlaque))
            plaque.size = CGSize(width: 820, height: 241)
            plaque.position = baseToStage(CGPoint(x: titleCenterX, y: titleY))
            plaque.zPosition = ZLayer.overlay + 1
            titleGroup.addChild(plaque)
        } else if let titlePlaqueTexture {
            let plaque = SKSpriteNode(texture: titlePlaqueTexture)
            plaque.size = CGSize(width: 680, height: 158)
            plaque.position = baseToStage(CGPoint(x: titleCenterX, y: titleY))
            plaque.zPosition = ZLayer.overlay + 1
            titleGroup.addChild(plaque)
        }

        let title = label("Bloodstream Defender", size: 48, color: UIColor(red: 1.0, green: 0.94, blue: 0.78, alpha: 1.0))
        title.position = baseToStage(CGPoint(x: titleCenterX, y: titleY + 18))
        title.zPosition = ZLayer.overlay + 4
        titleGroup.addChild(title)

        if let startSheetTexture {
            let bestFrame = SKSpriteNode(texture: regionTexture(from: startSheetTexture, frame: AtlasFrames.startBestRunFrame))
            bestFrame.size = CGSize(width: 1080, height: 170)
            bestFrame.position = baseToStage(CGPoint(x: bestRunCenterX, y: bestRunY))
            bestFrame.zPosition = ZLayer.overlay + 1
            titleGroup.addChild(bestFrame)
        }

        let bestRun = multilineLabel("", size: 30, color: UIColor(red: 1.0, green: 0.92, blue: 0.64, alpha: 1.0), width: 920, lines: 2)
        bestRun.position = baseToStage(CGPoint(x: bestRunCenterX, y: bestRunY))
        bestRun.zPosition = ZLayer.overlay + 4
        titleGroup.addChild(bestRun)
        bestRunLabel = bestRun

        if let startSheetTexture {
            let startFrame = SKSpriteNode(texture: regionTexture(from: startSheetTexture, frame: AtlasFrames.startRunButton))
            startFrame.size = CGSize(width: 380, height: 78)
            startFrame.position = baseToStage(CGPoint(x: startCenterX, y: startY))
            startFrame.zPosition = ZLayer.overlay + 1
            titleGroup.addChild(startFrame)
        }

        startButton = SKShapeNode(rectOf: CGSize(width: 380, height: 78), cornerRadius: 18)
        startButton.fillColor = UIColor(red: 0.10, green: 0.74, blue: 0.82, alpha: startSheetTexture == nil ? 0.88 : 0.001)
        startButton.strokeColor = startSheetTexture == nil ? UIColor(red: 1.0, green: 0.88, blue: 0.42, alpha: 0.95) : .clear
        startButton.lineWidth = startSheetTexture == nil ? 3 : 0
        startButton.position = baseToStage(CGPoint(x: startCenterX, y: startY))
        startButton.zPosition = ZLayer.overlay + 5
        titleGroup.addChild(startButton)

        let startLabel = label("START RUN", size: 26, color: UIColor(red: 1.0, green: 0.94, blue: 0.78, alpha: 1.0))
        startLabel.position = baseToStage(CGPoint(x: startCenterX, y: startY))
        startLabel.zPosition = ZLayer.overlay + 6
        titleGroup.addChild(startLabel)

        let howToPlay = addArtButton(
            to: titleGroup,
            center: CGPoint(x: centerX, y: howToPlayY),
            size: CGSize(width: 248, height: 54),
            title: "HOW TO PLAY",
            fontSize: 17
        )
        titleHowToPlayButton = howToPlay.shape

        let leaderboards = addArtButton(
            to: titleGroup,
            center: CGPoint(x: centerX, y: gameCenterY),
            size: CGSize(width: 248, height: 54),
            title: "LEADERBOARDS",
            fontSize: 17
        )
        leaderboardsButton = leaderboards.shape
        leaderboardsLabel = leaderboards.label

        overlayNode.addChild(titleGroup)
    }

    private func setupPauseOverlay() {
        pauseOverlay.removeAllChildren()
        pauseOverlay.addChild(overlayShade(alpha: 0.58))
        let pauseContentX: CGFloat = 624

        if let pauseCompleteTexture {
            let panel = SKSpriteNode(texture: regionTexture(from: pauseCompleteTexture, frame: AtlasFrames.pausePanel))
            panel.position = baseToStage(CGPoint(x: 640, y: 354))
            panel.size = CGSize(width: 418, height: 584)
            panel.zPosition = ZLayer.overlay + 1
            pauseOverlay.addChild(panel)
        } else {
            let panel = SKShapeNode(rectOf: CGSize(width: 418, height: 568), cornerRadius: 26)
            panel.fillColor = UIColor(red: 0.04, green: 0.01, blue: 0.04, alpha: 0.86)
            panel.strokeColor = UIColor(red: 0.38, green: 1.0, blue: 1.0, alpha: 0.72)
            panel.lineWidth = 2
            panel.position = baseToStage(CGPoint(x: 640, y: 354))
            pauseOverlay.addChild(panel)
        }

        let text = label("Paused", size: 46, color: UIColor(red: 1.0, green: 0.94, blue: 0.78, alpha: 1.0))
        text.position = baseToStage(CGPoint(x: pauseContentX, y: 178))
        pauseOverlay.addChild(text)

        let resume = addArtButton(to: pauseOverlay, center: CGPoint(x: pauseContentX, y: 244), size: CGSize(width: 212, height: 54), title: "Resume", fontSize: 19)
        resumeButton = resume.shape

        let audio = addArtButton(to: pauseOverlay, center: CGPoint(x: pauseContentX, y: 314), size: CGSize(width: 234, height: 54), title: "Audio & Feedback", fontSize: 15)
        audioSettingsButton = audio.shape
        audioSettingsLabel = audio.label

        let input = addArtButton(to: pauseOverlay, center: CGPoint(x: pauseContentX, y: 380), size: CGSize(width: 234, height: 54), title: "Input Settings", fontSize: 16)
        inputSettingsButton = input.shape
        inputSettingsLabel = input.label

        let howToPlay = addArtButton(to: pauseOverlay, center: CGPoint(x: pauseContentX, y: 446), size: CGSize(width: 234, height: 54), title: "How to Play", fontSize: 16)
        howToPlayButton = howToPlay.shape
        howToPlayLabel = howToPlay.label

        let restart = addArtButton(to: pauseOverlay, center: CGPoint(x: pauseContentX, y: 516), size: CGSize(width: 234, height: 54), title: "Restart Run", fontSize: 16)
        restartButton = restart.shape

        setupAudioSettingsOverlay()
        setupInputSettingsOverlay()
        setupHowToPlayOverlay()

        setupRestartConfirmOverlay()
        restartConfirmOverlay.zPosition = ZLayer.overlay + 80
        pauseOverlay.addChild(restartConfirmOverlay)

        pauseOverlay.isHidden = true
        overlayNode.addChild(pauseOverlay)
    }

    private func setupAudioSettingsOverlay() {
        audioSettingsOverlay.removeAllChildren()
        audioSettingsOverlay.zPosition = ZLayer.overlay + 58

        let shade = overlayShade(alpha: 0.62)
        shade.zPosition = ZLayer.overlay
        audioSettingsOverlay.addChild(shade)

        let panel = SKShapeNode(rectOf: CGSize(width: 600, height: 350), cornerRadius: 26)
        panel.fillColor = UIColor(red: 0.025, green: 0.0, blue: 0.025, alpha: 0.98)
        panel.strokeColor = UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 0.86)
        panel.lineWidth = 3
        panel.glowWidth = 6
        panel.position = baseToStage(CGPoint(x: 640, y: 396))
        panel.zPosition = ZLayer.overlay + 1
        audioSettingsOverlay.addChild(panel)

        let title = label("Audio & Feedback", size: 29, color: UIColor(red: 1.0, green: 0.92, blue: 0.84, alpha: 1.0))
        title.position = baseToStage(CGPoint(x: 640, y: 266))
        title.zPosition = ZLayer.overlay + 61
        audioSettingsOverlay.addChild(title)

        let back = addArtButton(to: audioSettingsOverlay, center: CGPoint(x: 470, y: 318), size: CGSize(width: 142, height: 50), title: "Back", fontSize: 15)
        audioSettingsBackButton = back.shape

        let music = addArtButton(to: audioSettingsOverlay, center: CGPoint(x: 640, y: 364), size: CGSize(width: 220, height: 52), title: "Music: On", fontSize: 16)
        musicToggleButton = music.shape
        musicToggleLabel = music.label

        let sfx = addArtButton(to: audioSettingsOverlay, center: CGPoint(x: 640, y: 424), size: CGSize(width: 220, height: 52), title: "Effects: On", fontSize: 16)
        sfxToggleButton = sfx.shape
        sfxToggleLabel = sfx.label

        let haptics = addArtButton(to: audioSettingsOverlay, center: CGPoint(x: 640, y: 484), size: CGSize(width: 220, height: 52), title: "Haptics: On", fontSize: 16)
        hapticsToggleButton = haptics.shape
        hapticsToggleLabel = haptics.label

        audioSettingsOverlay.isHidden = true
        pauseOverlay.addChild(audioSettingsOverlay)
    }

    private func setupInputSettingsOverlay() {
        inputSettingsOverlay.removeAllChildren()
        inputSettingsOverlay.zPosition = ZLayer.overlay + 58

        let shade = overlayShade(alpha: 0.62)
        shade.zPosition = ZLayer.overlay
        inputSettingsOverlay.addChild(shade)

        let panel = SKShapeNode(rectOf: CGSize(width: 620, height: 366), cornerRadius: 26)
        panel.fillColor = UIColor(red: 0.025, green: 0.0, blue: 0.025, alpha: 0.98)
        panel.strokeColor = UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 0.86)
        panel.lineWidth = 3
        panel.glowWidth = 6
        panel.position = baseToStage(CGPoint(x: 640, y: 396))
        panel.zPosition = ZLayer.overlay + 1
        inputSettingsOverlay.addChild(panel)

        let title = label("Input Settings", size: 29, color: UIColor(red: 1.0, green: 0.92, blue: 0.84, alpha: 1.0))
        title.position = baseToStage(CGPoint(x: 640, y: 266))
        title.zPosition = ZLayer.overlay + 61
        inputSettingsOverlay.addChild(title)

        let back = addArtButton(to: inputSettingsOverlay, center: CGPoint(x: 458, y: 314), size: CGSize(width: 142, height: 50), title: "Back", fontSize: 15)
        inputSettingsBackButton = back.shape

        let tilt = addArtButton(to: inputSettingsOverlay, center: CGPoint(x: 574, y: 370), size: CGSize(width: 166, height: 50), title: "Tilt: Off", fontSize: 15)
        tiltToggleButton = tilt.shape
        tiltToggleLabel = tilt.label

        let calibrate = addArtButton(to: inputSettingsOverlay, center: CGPoint(x: 738, y: 370), size: CGSize(width: 166, height: 50), title: "Calibrate", fontSize: 15)
        tiltCalibrateButton = calibrate.shape
        tiltCalibrateLabel = calibrate.label

        let sensitivityTitle = label("TILT SENSITIVITY", size: 13, color: UIColor(red: 0.45, green: 1.0, blue: 1.0, alpha: 1.0))
        sensitivityTitle.position = baseToStage(CGPoint(x: 640, y: 424))
        sensitivityTitle.zPosition = ZLayer.overlay + 61
        inputSettingsOverlay.addChild(sensitivityTitle)

        let sliderCenter = CGPoint(
            x: Constants.tiltSensitivitySliderLeftX + Constants.tiltSensitivitySliderWidth * 0.5,
            y: Constants.tiltSensitivitySliderY
        )
        tiltSensitivityTrack = SKShapeNode(rectOf: CGSize(width: Constants.tiltSensitivitySliderWidth, height: 8), cornerRadius: 4)
        tiltSensitivityTrack.fillColor = UIColor(red: 0.04, green: 0.0, blue: 0.04, alpha: 0.92)
        tiltSensitivityTrack.strokeColor = UIColor(red: 0.72, green: 1.0, blue: 1.0, alpha: 0.66)
        tiltSensitivityTrack.lineWidth = 1.5
        tiltSensitivityTrack.position = baseToStage(sliderCenter)
        tiltSensitivityTrack.zPosition = ZLayer.overlay + 61
        inputSettingsOverlay.addChild(tiltSensitivityTrack)

        tiltSensitivityFill = SKShapeNode(rectOf: CGSize(width: Constants.tiltSensitivitySliderWidth, height: 8), cornerRadius: 4)
        tiltSensitivityFill.fillColor = UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 0.78)
        tiltSensitivityFill.strokeColor = .clear
        tiltSensitivityFill.zPosition = ZLayer.overlay + 62
        inputSettingsOverlay.addChild(tiltSensitivityFill)

        tiltSensitivityKnob = SKShapeNode(circleOfRadius: 18)
        tiltSensitivityKnob.fillColor = UIColor(red: 1.0, green: 0.92, blue: 0.46, alpha: 0.96)
        tiltSensitivityKnob.strokeColor = UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 0.96)
        tiltSensitivityKnob.lineWidth = 2
        tiltSensitivityKnob.glowWidth = 4
        tiltSensitivityKnob.zPosition = ZLayer.overlay + 64
        inputSettingsOverlay.addChild(tiltSensitivityKnob)

        tiltSensitivityHitArea = SKShapeNode(rectOf: CGSize(width: Constants.tiltSensitivitySliderWidth + 64, height: 62), cornerRadius: 15)
        tiltSensitivityHitArea.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.001)
        tiltSensitivityHitArea.strokeColor = .clear
        tiltSensitivityHitArea.position = baseToStage(sliderCenter)
        tiltSensitivityHitArea.zPosition = ZLayer.overlay + 65
        inputSettingsOverlay.addChild(tiltSensitivityHitArea)

        let valueLabel = label("", size: 16, color: UIColor(red: 1.0, green: 0.92, blue: 0.64, alpha: 1.0))
        valueLabel.position = baseToStage(CGPoint(x: 640, y: 486))
        valueLabel.zPosition = ZLayer.overlay + 61
        inputSettingsOverlay.addChild(valueLabel)
        tiltSensitivityLabel = valueLabel

        setupTiltCalibrationToast(center: CGPoint(x: 640, y: 548))
        inputSettingsOverlay.addChild(tiltCalibrationToast)

        inputSettingsOverlay.isHidden = true
        pauseOverlay.addChild(inputSettingsOverlay)
        updateTiltSensitivitySlider()
    }

    private func setupHowToPlayOverlay() {
        howToPlayOverlay.removeAllChildren()
        howToPlayOverlay.zPosition = ZLayer.overlay + 58

        let shade = overlayShade(alpha: howToPlayTexture == nil ? 0.62 : 0.36)
        shade.zPosition = ZLayer.overlay
        howToPlayOverlay.addChild(shade)

        if let howToPlayTexture {
            let page = SKSpriteNode(texture: howToPlayTexture)
            page.size = Constants.baseSize
            page.position = baseToStage(CGPoint(x: Constants.baseSize.width * 0.5, y: Constants.baseSize.height * 0.5))
            page.zPosition = ZLayer.overlay + 1
            howToPlayOverlay.addChild(page)

            let back = addArtButton(to: howToPlayOverlay, center: CGPoint(x: 132, y: 66), size: CGSize(width: 146, height: 52), title: "Back", fontSize: 16)
            howToPlayBackButton = back.shape

            howToPlayOverlay.isHidden = true
            overlayNode.addChild(howToPlayOverlay)
            return
        }

        let panel = SKShapeNode(rectOf: CGSize(width: 780, height: 448), cornerRadius: 24)
        panel.fillColor = UIColor(red: 0.025, green: 0.0, blue: 0.025, alpha: 0.98)
        panel.strokeColor = UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 0.86)
        panel.lineWidth = 3
        panel.glowWidth = 6
        panel.position = baseToStage(CGPoint(x: 640, y: 394))
        panel.zPosition = ZLayer.overlay + 1
        howToPlayOverlay.addChild(panel)

        let title = label("How to Play", size: 29, color: UIColor(red: 1.0, green: 0.92, blue: 0.84, alpha: 1.0))
        title.position = baseToStage(CGPoint(x: 640, y: 204))
        title.zPosition = ZLayer.overlay + 61
        howToPlayOverlay.addChild(title)

        let back = addArtButton(to: howToPlayOverlay, center: CGPoint(x: 330, y: 258), size: CGSize(width: 146, height: 52), title: "Back", fontSize: 16)
        howToPlayBackButton = back.shape

        addHowToPlaySection(
            title: "Core Loop",
            body: "Move through the vessel, fire antibodies, and survive until each section is clear.\nDash slips out of danger. Pulse clears nearby threats once unlocked.",
            x: 455,
            y: 310
        )
        addHowToPlaySection(
            title: "Adaptations",
            body: "After sections, choose antibody output, complement pulse, or chemotaxis movement.\nEach rank stacks, so a run slowly becomes your build.",
            x: 455,
            y: 456
        )
        addHowToPlaySection(
            title: "Boss Reads",
            body: "Rotavirus: shoot through open shield windows.\nLyssavirus: dodge the charge, then punish the exposed recovery.\nNorovirus: clear decoys and sidestep launched orbs.",
            x: 800,
            y: 310
        )

        howToPlayOverlay.isHidden = true
        overlayNode.addChild(howToPlayOverlay)
    }

    private func addHowToPlaySection(title: String, body: String, x: CGFloat, y: CGFloat) {
        let heading = label(title, size: 17, color: UIColor(red: 0.45, green: 1.0, blue: 1.0, alpha: 1.0))
        heading.position = baseToStage(CGPoint(x: x, y: y))
        heading.zPosition = ZLayer.overlay + 61
        howToPlayOverlay.addChild(heading)

        let bodyLabel = multilineLabel(body, size: 14, color: UIColor(red: 1.0, green: 0.92, blue: 0.76, alpha: 1.0), width: 278, lines: 5)
        bodyLabel.position = baseToStage(CGPoint(x: x, y: y + 38))
        bodyLabel.zPosition = ZLayer.overlay + 61
        howToPlayOverlay.addChild(bodyLabel)
    }

    private func setupTiltCalibrationToast(center: CGPoint) {
        tiltCalibrationToast.removeAllChildren()
        tiltCalibrationToast.removeAllActions()
        tiltCalibrationToast.position = baseToStage(center)
        tiltCalibrationToast.zPosition = ZLayer.overlay + 70
        tiltCalibrationToast.alpha = 0
        tiltCalibrationToast.isHidden = true
        tiltCalibrationToast.setScale(1.0)

        let frame = SKShapeNode(rectOf: CGSize(width: 188, height: 58), cornerRadius: 18)
        frame.fillColor = UIColor(red: 0.02, green: 0.0, blue: 0.03, alpha: 0.94)
        frame.strokeColor = UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 0.95)
        frame.lineWidth = 2
        frame.glowWidth = 6
        tiltCalibrationToast.addChild(frame)
        tiltCalibrationToastFrame = frame

        let text = label("CENTERED", size: 20, color: UIColor(red: 1.0, green: 0.96, blue: 0.78, alpha: 1.0))
        text.position = .zero
        tiltCalibrationToast.addChild(text)
        tiltCalibrationToastLabel = text
    }

    private func setupRestartConfirmOverlay() {
        restartConfirmOverlay.removeAllChildren()
        restartConfirmOverlay.addChild(overlayShade(alpha: 0.76))
        let panel = SKShapeNode(rectOf: CGSize(width: 500, height: 246), cornerRadius: 24)
        panel.fillColor = UIColor(red: 0.025, green: 0.0, blue: 0.025, alpha: 0.98)
        panel.strokeColor = UIColor(red: 1.0, green: 0.76, blue: 0.34, alpha: 0.96)
        panel.lineWidth = 3
        panel.glowWidth = 5
        panel.position = baseToStage(CGPoint(x: 640, y: 360))
        panel.zPosition = ZLayer.overlay + 20
        restartConfirmOverlay.addChild(panel)

        let title = label("Restart this run?", size: 28, color: UIColor(red: 1.0, green: 0.92, blue: 0.84, alpha: 1.0))
        title.position = baseToStage(CGPoint(x: 640, y: 300))
        title.zPosition = ZLayer.overlay + 21
        restartConfirmOverlay.addChild(title)

        let body = multilineLabel("Current score and adaptations will reset.", size: 15, color: UIColor(red: 0.80, green: 1.0, blue: 1.0, alpha: 1.0), width: 390, lines: 2)
        body.position = baseToStage(CGPoint(x: 640, y: 357))
        body.zPosition = ZLayer.overlay + 21
        restartConfirmOverlay.addChild(body)

        let cancel = addArtButton(to: restartConfirmOverlay, center: CGPoint(x: 550, y: 432), size: CGSize(width: 158, height: 54), title: "Cancel", fontSize: 16)
        restartCancelButton = cancel.shape
        let confirm = addArtButton(to: restartConfirmOverlay, center: CGPoint(x: 730, y: 432), size: CGSize(width: 158, height: 54), title: "Restart", fontSize: 16)
        restartConfirmButton = confirm.shape
        restartConfirmOverlay.isHidden = true
    }

    private func setupLevelCompleteOverlay() {
        levelCompleteOverlay.removeAllChildren()
        levelCompleteOverlay.addChild(overlayShade(alpha: 0.56))

        if let pauseCompleteTexture {
            let panel = SKSpriteNode(texture: regionTexture(from: pauseCompleteTexture, frame: AtlasFrames.completePanel))
            panel.position = baseToStage(CGPoint(x: 640, y: 344))
            panel.size = CGSize(width: 860, height: 470)
            panel.zPosition = ZLayer.overlay + 1
            levelCompleteOverlay.addChild(panel)
        } else {
            let panel = SKShapeNode(rectOf: CGSize(width: 860, height: 470), cornerRadius: 28)
            panel.fillColor = UIColor(red: 0.04, green: 0.01, blue: 0.04, alpha: 0.86)
            panel.strokeColor = UIColor(red: 0.38, green: 1.0, blue: 1.0, alpha: 0.72)
            panel.lineWidth = 2
            panel.position = baseToStage(CGPoint(x: 640, y: 344))
            levelCompleteOverlay.addChild(panel)
        }

        let title = label("Level Complete", size: 50, color: UIColor(red: 1.0, green: 0.94, blue: 0.78, alpha: 1.0))
        title.position = baseToStage(CGPoint(x: 640, y: 264))
        levelCompleteOverlay.addChild(title)
        levelCompleteTitleLabel = title

        let body = multilineLabel("", size: 20, color: UIColor(red: 0.88, green: 1.0, blue: 0.9, alpha: 1.0), width: 610, lines: 5)
        body.position = baseToStage(CGPoint(x: 640, y: 374))
        levelCompleteOverlay.addChild(body)
        levelCompleteBodyLabel = body

        let action = addArtButton(to: levelCompleteOverlay, center: CGPoint(x: 640, y: 500), size: CGSize(width: 292, height: 58), title: "Choose Adaptation", fontSize: 20)
        levelCompleteActionButton = action.shape
        levelCompleteActionLabel = action.label
        action.label.position = baseToStage(CGPoint(x: 648, y: 502))

        levelCompleteOverlay.isHidden = true
        overlayNode.addChild(levelCompleteOverlay)
    }

    private func setupUpgradeOverlay() {
        upgradeOverlay.removeAllChildren()
        upgradeButtons.removeAll()
        upgradeRankLabels.removeAll()
        upgradeNextRankLabels.removeAll()
        upgradeButtonLabels.removeAll()
        upgradePips.removeAll()

        upgradeOverlay.addChild(overlayShade(alpha: 0.68))

        if let upgradeTitlePlaqueTexture {
            let plaque = SKSpriteNode(texture: upgradeTitlePlaqueTexture)
            plaque.position = baseToStage(CGPoint(x: 640, y: 116))
            plaque.size = CGSize(width: 756, height: 176)
            plaque.zPosition = ZLayer.overlay + 1
            upgradeOverlay.addChild(plaque)
        }

        let intro = label("", size: 15, color: UIColor(red: 1.0, green: 0.94, blue: 0.84, alpha: 1.0))
        intro.position = baseToStage(CGPoint(x: 640, y: 206))
        upgradeOverlay.addChild(intro)
        upgradeIntroLabel = intro

        let branchTitleData = [
            (Constants.upgrades[0], CGPoint(x: 330, y: 440), "ANTIBODY OUTPUT"),
            (Constants.upgrades[1], CGPoint(x: 640, y: 440), "COMPLEMENT DEFENSE"),
            (Constants.upgrades[2], CGPoint(x: 950, y: 440), "CELL MOVEMENT")
        ]

        for (definition, center, branchTitle) in branchTitleData {
            let branchPosition = baseToStage(CGPoint(x: center.x, y: 240))
            let branchShadow = label(branchTitle, size: 14.5, color: UIColor(red: 0.0, green: 0.0, blue: 0.02, alpha: 0.86))
            branchShadow.position = CGPoint(x: branchPosition.x + 1.5, y: branchPosition.y - 1.5)
            branchShadow.zPosition = ZLayer.overlay + 9
            upgradeOverlay.addChild(branchShadow)

            let branch = label(branchTitle, size: 14.5, color: UIColor(red: 0.76, green: 1.0, blue: 1.0, alpha: 1.0))
            branch.position = branchPosition
            branch.zPosition = ZLayer.overlay + 10
            upgradeOverlay.addChild(branch)
            addUpgradeCard(definition: definition, center: center)
        }

        upgradeOverlay.isHidden = true
        overlayNode.addChild(upgradeOverlay)
    }

    private func addUpgradeCard(definition: UpgradeDefinition, center: CGPoint) {
        let card = SKShapeNode(rectOf: CGSize(width: 306, height: 342), cornerRadius: 12)
        card.fillColor = upgradeCardFillColor(for: definition.choice)
        card.strokeColor = definition.accent.withAlphaComponent(0.90)
        card.lineWidth = 2
        card.glowWidth = 3
        card.position = baseToStage(center)
        card.zPosition = ZLayer.overlay + 2
        upgradeOverlay.addChild(card)
        upgradeButtons[card] = definition.choice

        if let medallionTexture = upgradeMedallionTextures[definition.choice] {
            let medallion = SKSpriteNode(texture: medallionTexture)
            medallion.position = baseToStage(CGPoint(x: center.x, y: center.y - 174))
            medallion.size = CGSize(width: 56, height: 56)
            medallion.zPosition = ZLayer.overlay + 5
            upgradeOverlay.addChild(medallion)
        }

        let termLabel = label(definition.term.uppercased(), size: 13.4, color: definition.accent)
        termLabel.position = baseToStage(CGPoint(x: center.x, y: center.y - 140))
        upgradeOverlay.addChild(termLabel)

        let titleSize: CGFloat = definition.title.count > 20 ? 24 : 25
        let titleLabel = label(definition.title, size: titleSize, color: UIColor(red: 1.0, green: 0.94, blue: 0.78, alpha: 1.0))
        titleLabel.position = baseToStage(CGPoint(x: center.x, y: center.y - 106))
        upgradeOverlay.addChild(titleLabel)

        let controlLabel = multilineLabel(definition.controls, size: 16.4, color: UIColor(red: 0.66, green: 1.0, blue: 1.0, alpha: 1.0), width: 276, lines: 2)
        controlLabel.position = baseToStage(CGPoint(x: center.x, y: center.y - 58))
        upgradeOverlay.addChild(controlLabel)

        let bodyLabel = multilineLabel(definition.body, size: 14.8, color: UIColor(red: 0.88, green: 0.94, blue: 0.9, alpha: 1.0), width: 282, lines: 4)
        bodyLabel.position = baseToStage(CGPoint(x: center.x, y: center.y + 4))
        upgradeOverlay.addChild(bodyLabel)

        let progressPanel = SKShapeNode(rectOf: CGSize(width: 278, height: 96), cornerRadius: 8)
        progressPanel.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.015, alpha: 0.32)
        progressPanel.strokeColor = definition.accent.withAlphaComponent(0.28)
        progressPanel.lineWidth = 1
        progressPanel.position = baseToStage(CGPoint(x: center.x, y: center.y + 96))
        progressPanel.zPosition = ZLayer.overlay + 3
        upgradeOverlay.addChild(progressPanel)

        let currentX = center.x - 129
        let rankLabel = multilineLabel("", size: 14.4, color: UIColor(red: 0.82, green: 1.0, blue: 1.0, alpha: 1.0), width: 258, lines: 2)
        rankLabel.horizontalAlignmentMode = .left
        rankLabel.position = baseToStage(CGPoint(x: currentX, y: center.y + 68))
        upgradeOverlay.addChild(rankLabel)
        upgradeRankLabels[definition.choice] = rankLabel

        let nextLabel = multilineLabel("", size: 15.0, color: UIColor(red: 1.0, green: 0.83, blue: 0.34, alpha: 1.0), width: 258, lines: 2)
        nextLabel.horizontalAlignmentMode = .left
        nextLabel.position = baseToStage(CGPoint(x: currentX, y: center.y + 116))
        upgradeOverlay.addChild(nextLabel)
        upgradeNextRankLabels[definition.choice] = nextLabel

        var pips: [SKShapeNode] = []
        for index in 0..<Constants.maxUpgradeRank {
            let pip = SKShapeNode(circleOfRadius: 6)
            pip.position = baseToStage(CGPoint(x: center.x - 39 + CGFloat(index) * 26, y: center.y + 152))
            pip.lineWidth = 1.5
            pip.zPosition = ZLayer.overlay + 5
            upgradeOverlay.addChild(pip)
            pips.append(pip)
        }
        upgradePips[definition.choice] = pips

        let pick = addArtButton(to: upgradeOverlay, center: CGPoint(x: center.x, y: center.y + 200), size: CGSize(width: 188, height: 30), title: "Choose", fontSize: 13)
        upgradeButtons[pick.shape] = definition.choice
        upgradeButtonLabels[definition.choice] = pick.label
    }

    private func upgradeCardFillColor(for choice: UpgradeChoice) -> UIColor {
        switch choice {
        case .rapid:
            return UIColor(red: 0.025, green: 0.125, blue: 0.155, alpha: 0.90)
        case .pulse:
            return UIColor(red: 0.135, green: 0.035, blue: 0.165, alpha: 0.90)
        case .dash:
            return UIColor(red: 0.035, green: 0.135, blue: 0.085, alpha: 0.90)
        }
    }

    private func setupGameOverOverlay() {
        gameOverOverlay.removeAllChildren()
        gameOverStatLabels.removeAll()
        gameOverAdaptationsLabel = nil
        gameOverOverlay.addChild(overlayShade(alpha: 0.66))

        let panelCenter = CGPoint(x: 640, y: 364)
        let panelScale: CGFloat = 1.45
        func panelPoint(_ point: CGPoint) -> CGPoint {
            CGPoint(
                x: panelCenter.x + (point.x - panelCenter.x) * panelScale,
                y: panelCenter.y + (point.y - panelCenter.y) * panelScale
            )
        }

        if let gameOverPanelTexture {
            let panel = SKSpriteNode(texture: gameOverPanelTexture)
            panel.position = baseToStage(panelCenter)
            panel.size = CGSize(width: 860 * panelScale, height: 484 * panelScale)
            panel.zPosition = ZLayer.overlay + 1
            gameOverOverlay.addChild(panel)
        } else {
            let panel = SKShapeNode(rectOf: CGSize(width: 860 * panelScale, height: 484 * panelScale), cornerRadius: 24 * panelScale)
            panel.fillColor = UIColor(red: 0.05, green: 0.00, blue: 0.03, alpha: 0.86)
            panel.strokeColor = UIColor(red: 1.0, green: 0.52, blue: 0.42, alpha: 0.78)
            panel.lineWidth = 3
            panel.position = baseToStage(panelCenter)
            gameOverOverlay.addChild(panel)
        }

        let title = label("IMMUNE RUN COMPLETE", size: 24 * panelScale, color: UIColor(red: 1.0, green: 0.92, blue: 0.84, alpha: 1.0))
        title.position = baseToStage(panelPoint(CGPoint(x: 640, y: 222)))
        gameOverOverlay.addChild(title)

        let subtitle = label("", size: 9 * panelScale, color: UIColor(red: 1.0, green: 0.92, blue: 0.84, alpha: 1.0))
        subtitle.position = baseToStage(panelPoint(CGPoint(x: 640, y: 254)))
        gameOverOverlay.addChild(subtitle)
        gameOverSubtitleLabel = subtitle

        let rightBoxTextX: CGFloat = 686

        let record = multilineLabel("", size: 11.4 * panelScale, color: UIColor(red: 1.0, green: 0.82, blue: 0.34, alpha: 1.0), width: 230 * panelScale, lines: 3)
        record.horizontalAlignmentMode = .left
        record.position = baseToStage(panelPoint(CGPoint(x: rightBoxTextX, y: 456)))
        gameOverOverlay.addChild(record)
        gameOverRecordLabel = record

        let leftStatTextX: CGFloat = 446
        let statDefs: [(key: String, title: String, titleY: CGFloat, valueY: CGFloat)] = [
            ("score", "FINAL SCORE", 308, 322),
            ("level", "LEVEL REACHED", 356, 370),
            ("sections", "SECTIONS CLEARED", 404, 418),
            ("virions", "VIRIONS NEUTRALIZED", 452, 466)
        ]

        for (key, title, titleY, valueY) in statDefs {
            let titleLabel = label(title, size: 10.1 * panelScale, color: UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 1.0))
            titleLabel.horizontalAlignmentMode = .left
            titleLabel.position = baseToStage(panelPoint(CGPoint(x: leftStatTextX, y: titleY)))
            gameOverOverlay.addChild(titleLabel)

            let value = label("0", size: 16.5 * panelScale, color: UIColor(red: 1.0, green: 0.96, blue: 0.78, alpha: 1.0))
            value.horizontalAlignmentMode = .left
            value.position = baseToStage(panelPoint(CGPoint(x: leftStatTextX, y: valueY)))
            gameOverOverlay.addChild(value)
            gameOverStatLabels[key] = value
        }

        let detailDefs: [(String, String, CGPoint)] = [
            ("time", "SURVIVAL TIME", CGPoint(x: rightBoxTextX, y: 338)),
            ("bosses", "BOSSES NEUTRALIZED", CGPoint(x: rightBoxTextX, y: 392))
        ]

        for (key, title, point) in detailDefs {
            let titleLabel = label(title, size: 11.4 * panelScale, color: UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 1.0))
            titleLabel.horizontalAlignmentMode = .left
            titleLabel.position = baseToStage(panelPoint(point))
            gameOverOverlay.addChild(titleLabel)

            let value = label("0", size: (key == "time" ? 36 : 34) * panelScale, color: UIColor(red: 1.0, green: 0.96, blue: 0.78, alpha: 1.0))
            value.horizontalAlignmentMode = .left
            value.position = baseToStage(panelPoint(CGPoint(x: point.x, y: point.y + 28)))
            gameOverOverlay.addChild(value)
            gameOverStatLabels[key] = value
        }

        let tryAgain = addArtButton(
            to: gameOverOverlay,
            center: panelPoint(CGPoint(x: 638, y: 527)),
            size: CGSize(width: 270 * panelScale, height: 46 * panelScale),
            title: "TRY AGAIN",
            fontSize: 18 * panelScale,
            drawFrame: false
        )
        tryAgainButton = tryAgain.shape
        gameOverOverlay.isHidden = true
        overlayNode.addChild(gameOverOverlay)
    }

    private func showBanner(_ text: String) {
        guard let bannerLabel else {
            return
        }
        let titleBanner = mode == .title
        bannerLabel.removeAllActions()
        bannerLabel.text = text
        bannerLabel.fontSize = titleBanner ? 15 : 24
        bannerLabel.position = baseToStage(CGPoint(x: 640, y: titleBanner ? 706 : 196))
        bannerLabel.alpha = 0
        bannerLabel.setScale(0.96)
        bannerLabel.run(.sequence([
            .group([
                .fadeIn(withDuration: 0.16),
                .scale(to: 1.0, duration: 0.16)
            ]),
            .wait(forDuration: 1.45),
            .fadeOut(withDuration: 0.35)
        ]))
    }

    private func showTitle() {
        mode = .title
        updateTitleBestRunLabel()
        titleGroup.isHidden = false
        pauseOverlay.isHidden = true
        closePauseSubmenus()
        levelCompleteOverlay.isHidden = true
        upgradeOverlay.isHidden = true
        gameOverOverlay.isHidden = true
        restartConfirmVisible = false
        restartConfirmOverlay.isHidden = true
        hudNode.isHidden = true
        controlsNode.isHidden = true
        playerNode?.isHidden = true
        fireTouchIds.removeAll()
        stopBossEncounterSFX()
        audio.playMusic(.menu)
        audio.stopAmbience()
    }

    private func startRun() {
        clearRunEntities(resetEnemyIds: true)
        player = PlayerState()
        player.invulnerable = 4.0
        score = 0
        sectionsCleared = 0
        totalKills = 0
        bossesNeutralized = 0
        lastRunWasBest = false
        runTime = 0
        levelClearTimer = 0
        bossHitFeedbackTimer = 0
        pendingMusicCue = nil
        pendingMusicTimer = 0
        dangerMusicActive = false
        rapidRank = 0
        pulseRank = 0
        dashRank = 0
        dashInputHeld = false
        horizontalSwimSoundInput = 0
        dashTrailTimer = 0
        swimWakeTimer = 0
        lastFacing = CGVector(dx: 1, dy: 0)
        tiltVector = .zero
        clearScreenShake()
        lockTargetId = nil
        joystickVector = .zero
        fireTouchIds.removeAll()
        titleGroup.isHidden = true
        pauseOverlay.isHidden = true
        closePauseSubmenus()
        levelCompleteOverlay.isHidden = true
        upgradeOverlay.isHidden = true
        gameOverOverlay.isHidden = true
        restartConfirmVisible = false
        restartConfirmOverlay.isHidden = true
        hudNode.isHidden = false
        controlsNode.isHidden = false
        playerNode?.isHidden = false
        loadLevel(1, clearEntities: false)
        updateJoystickVisual()
        updateHUD()
        updateAbilityControls()
        mode = .running
        stopBossEncounterSFX()
        audio.playMusic(.combat)
        audio.playAmbience()
    }

    private func startNextLevel() {
        lockTargetId = nil
        joystickVector = .zero
        fireTouchIds.removeAll()
        player.health = min(Constants.playerMaxHealth, player.health + 25)
        dangerMusicActive = false
        player.position = CGPoint(x: 210, y: 360)
        player.velocity = .zero
        player.shootCooldown = 0
        player.dashCooldown = 0
        player.pulseCooldown = 0
        player.invulnerable = 1.6
        player.hurtTimer = 0
        horizontalSwimSoundInput = 0
        dashTrailTimer = 0
        swimWakeTimer = 0
        lastFacing = CGVector(dx: 1, dy: 0)
        tiltVector = .zero
        loadLevel(level + 1, clearEntities: true)
        pauseOverlay.isHidden = true
        closePauseSubmenus()
        levelCompleteOverlay.isHidden = true
        upgradeOverlay.isHidden = true
        gameOverOverlay.isHidden = true
        restartConfirmVisible = false
        restartConfirmOverlay.isHidden = true
        controlsNode.isHidden = false
        hudNode.isHidden = false
        updateJoystickVisual()
        updateHUD()
        updateAbilityControls()
        mode = .running
        stopBossEncounterSFX()
        playDesiredMusic()
        audio.playAmbience()
    }

    private func loadLevel(_ nextLevel: Int, clearEntities: Bool) {
        if clearEntities {
            clearRunEntities(resetEnemyIds: false)
        }

        level = nextLevel
        levelKills = 0
        scroll = 0
        levelClearTimer = 0
        activeMission = mission(for: level)
        let difficulty = difficultyMultiplier(for: level)
        let baseLength = 2200 + CGFloat(level) * (activeMission.isEncounter ? 560 : 520)
        levelLength = round(baseLength * (1 + max(0, difficulty - 1) * 0.18))
        levelGoal = min(85, Int(ceil((3 + CGFloat(level) * 2) * difficulty)))
        spawnEnemyTimer = level == 1 ? 0.9 : 0.15
        spawnRedTimer = 0.25
        spawnPlateletTimer = TimeInterval.random(in: 1.15...2.1)
        bossWarningTimer = 0
        bossClearTimer = 0
        bossHitFeedbackTimer = 0
        bossWarningStarted = false
        bossSpawned = false
        bossDefeated = false
        bossTriggerProgress = activeMission.isEncounter ? CGFloat.random(in: 0.80...0.90) : 0.85
        lockTargetId = nil
        seedRedCells()
        seedPlatelets()
        showBanner("\(activeMission.name): \(activeMission.term)")
        playerNode?.position = baseToStage(player.position)
        playerNode?.zRotation = 0
        updateBackground()
    }

    private func mission(for value: Int) -> MissionDefinition {
        if value <= Constants.missions.count {
            return Constants.missions[value - 1]
        }
        let index = (value - Constants.missions.count - 1) % Constants.encounters.count
        return Constants.encounters[index]
    }

    private func difficultyMultiplier(for measuredLevel: Int? = nil) -> CGFloat {
        let pressureLevel = difficultyPressureLevel(for: measuredLevel)
        guard pressureLevel > 4 else {
            return 1
        }
        return pow(1.2, pressureLevel - 4)
    }

    private func difficultyPressureLevel(for measuredLevel: Int? = nil) -> CGFloat {
        let measuredLevel = CGFloat(measuredLevel ?? level)
        guard measuredLevel > 4 else {
            return measuredLevel
        }
        let oldHotLevel: CGFloat = 14
        let newHotLevel: CGFloat = 20
        let rampScale = (oldHotLevel - 4) / (newHotLevel - 4)
        return 4 + (measuredLevel - 4) * rampScale
    }

    private func levelProgress() -> CGFloat {
        clamp(scroll / max(levelLength, 1), 0, 1)
    }

    private func levelSpawnScale() -> CGFloat {
        let difficulty = difficultyMultiplier()
        let pressureLevel = difficultyPressureLevel()
        let baseSpawnScale: CGFloat
        if activeMission.isEncounter {
            baseSpawnScale = max(0.42, 0.86 - pressureLevel * 0.035)
        } else {
            baseSpawnScale = max(0.58, 1.0 - pressureLevel * 0.055)
        }
        return max(0.28, baseSpawnScale / sqrt(difficulty))
    }

    private func liveEnemyCount() -> Int {
        enemies.filter { !$0.dead }.count
    }

    private func liveInfluenzaCount() -> Int {
        enemies.filter { !$0.dead && $0.kind == .influenza }.count
    }

    private func influenzaCap() -> Int {
        guard level >= 4 else {
            return 0
        }
        return min(30, 12 + max(0, level - 4) * 3)
    }

    private func activePlateletCount() -> Int {
        platelets.filter { !$0.dead }.count
    }

    private func plateletLimit() -> Int {
        if activeMission.isEncounter {
            return min(Constants.plateletMaxActive, 2 + (level >= 5 ? 1 : 0) + (level >= 9 ? 1 : 0))
        }
        return min(Constants.plateletMaxActive, 2 + (level >= 4 ? 1 : 0) + (level >= 7 ? 1 : 0) + (level >= 10 ? 1 : 0))
    }

    private func plateletTargetCount() -> Int {
        plateletLimit()
    }

    private func nextPlateletSpawnDelay(spawnScale: CGFloat) -> TimeInterval {
        let intensity = clamp(CGFloat(level - 1) / 8, 0, 1)
        var minimum = CGFloat.lerp(from: 3.7, to: 2.25, amount: intensity)
        var maximum = CGFloat.lerp(from: 6.25, to: 4.25, amount: intensity)
        if CGFloat.random(in: 0...1) < CGFloat.lerp(from: 0.12, to: 0.28, amount: intensity) {
            minimum *= 0.58
            maximum *= 0.68
        }
        return TimeInterval(CGFloat.random(in: minimum...maximum) * max(0.74, spawnScale))
    }

    private func activeBoss() -> Enemy? {
        enemies.first { !$0.dead && $0.kind == .boss && $0.hp > 0 }
    }

    private func bossProfile(for kind: BossKind) -> BossProfile? {
        switch kind {
        case .pox:
            guard let poxBossTexture else {
                return nil
            }
            return BossProfile(
                title: "Pox-Brick Boss",
                kind: .pox,
                frames: AtlasFrames.poxBoss,
                texture: poxBossTexture,
                radius: 86,
                hp: 120,
                score: 650,
                damage: 28,
                damageScale: 0.38,
                targetX: 0.73,
                attackInterval: 2.2,
                visualScale: 0.52
            )
        case .adenovirus:
            guard let adenovirusTexture else {
                return nil
            }
            return BossProfile(
                title: "Adenovirus Prism",
                kind: .adenovirus,
                frames: AtlasFrames.adenovirus,
                texture: adenovirusTexture,
                radius: 58,
                hp: 56,
                score: 360,
                damage: 20,
                damageScale: 0.52,
                targetX: 0.68,
                attackInterval: 2.1,
                visualScale: 0.36
            )
        case .filovirus:
            guard let filovirusTexture else {
                return nil
            }
            return BossProfile(
                title: "Filovirus Ribbon",
                kind: .filovirus,
                frames: AtlasFrames.filovirus,
                texture: filovirusTexture,
                radius: 74,
                hp: 128,
                score: 720,
                damage: 24,
                damageScale: 0.46,
                targetX: 0.64,
                attackInterval: 2.7,
                visualScale: 0.38
            )
        case .rotavirus:
            guard let rotavirusTexture else {
                return nil
            }
            return BossProfile(
                title: "Rotavirus Gyre",
                kind: .rotavirus,
                frames: AtlasFrames.rotavirus,
                texture: rotavirusTexture,
                radius: 78,
                hp: 112,
                score: 680,
                damage: 24,
                damageScale: 0.46,
                targetX: 0.72,
                attackInterval: 2.55,
                visualScale: 0.47
            )
        case .lyssavirus:
            guard let lyssavirusTexture else {
                return nil
            }
            return BossProfile(
                title: "Lyssavirus Lance",
                kind: .lyssavirus,
                frames: AtlasFrames.lyssavirus,
                texture: lyssavirusTexture,
                radius: 62,
                hp: 110,
                score: 640,
                damage: 30,
                damageScale: 0.47,
                targetX: 0.78,
                attackInterval: 3.45,
                visualScale: 0.52
            )
        case .norovirus:
            guard let norovirusTexture else {
                return nil
            }
            return BossProfile(
                title: "Norovirus Swarm-Core",
                kind: .norovirus,
                frames: AtlasFrames.norovirus,
                texture: norovirusTexture,
                radius: 76,
                hp: 108,
                score: 690,
                damage: 22,
                damageScale: 0.47,
                targetX: 0.71,
                attackInterval: 3.0,
                visualScale: 0.48
            )
        }
    }

    private func clearRunEntities(resetEnemyIds: Bool) {
        enemies.forEach { $0.node.removeFromParent() }
        redCells.forEach { $0.node.removeFromParent() }
        platelets.forEach { $0.node.removeFromParent() }
        shots.forEach { recycleShot($0) }
        activePulses.forEach { pulse in
            pulse.visuals.forEach { $0.node.removeFromParent() }
        }
        enemies.removeAll()
        redCells.removeAll()
        platelets.removeAll()
        shots.removeAll()
        activePulses.removeAll()
        clearParticleChildrenForRun()
        if resetEnemyIds {
            nextEnemyId = 1
        }
    }

    private var cosmeticLoadSheddingActive: Bool {
        let liveShotCount = shots.reduce(0) { count, shot in count + (shot.dead ? 0 : 1) }
        let liveEnemyCount = enemies.reduce(0) { count, enemy in count + (enemy.dead ? 0 : 1) }
        let particleCount = particleNode.children.count

        if particleCount >= Constants.cosmeticParticleSoftCap || liveShotCount >= 48 {
            return true
        }
        if liveEnemyCount >= 18 && liveShotCount >= 24 {
            return true
        }
        return level >= 14 && (liveEnemyCount >= 15 || liveShotCount >= 32)
    }

    private var currentCosmeticFrameBudget: Int {
        cosmeticLoadSheddingActive ? Constants.cosmeticSparkFrameBudgetUnderLoad : Constants.cosmeticSparkFrameBudget
    }

    private func reserveCosmeticNodes(requested: Int, keepOneWhenTight: Bool = false) -> Int {
        guard requested > 0 else {
            return 0
        }

        let activeParticles = particleNode.children.count
        guard activeParticles < Constants.cosmeticParticleHardCap else {
            return 0
        }

        let frameRemaining = max(0, currentCosmeticFrameBudget - cosmeticNodesSpawnedThisFrame)
        guard frameRemaining > 0 else {
            return 0
        }

        var allowed = min(requested, frameRemaining, Constants.cosmeticParticleHardCap - activeParticles)
        if cosmeticLoadSheddingActive {
            let tightBurstLimit = max(keepOneWhenTight ? 1 : 0, Int(ceil(CGFloat(requested) * 0.45)))
            allowed = min(allowed, tightBurstLimit)
        }
        if activeParticles >= Constants.cosmeticParticleSoftCap {
            allowed = min(allowed, keepOneWhenTight ? 1 : 0)
        }

        cosmeticNodesSpawnedThisFrame += allowed
        return allowed
    }

    private func reserveCosmeticNode() -> Bool {
        reserveCosmeticNodes(requested: 1) > 0
    }

    private func reserveHitFlash(for enemy: Enemy) -> Bool {
        let budget = cosmeticLoadSheddingActive ? Constants.cosmeticHitFlashFrameBudgetUnderLoad : Constants.cosmeticHitFlashFrameBudget
        guard hitFlashesThisFrame < budget else {
            return false
        }
        hitFlashesThisFrame += 1
        return true
    }

    private func dequeueShot(
        texture: SKTexture,
        size: CGSize,
        start: CGPoint,
        aim: CGVector,
        velocity: CGVector,
        damage: CGFloat,
        targetId: Int?
    ) -> Shot {
        let shot: Shot
        let node: SKSpriteNode
        if let pooledShot = shotPool.popLast() {
            shot = pooledShot
            node = pooledShot.node
            node.texture = texture
        } else {
            node = SKSpriteNode(texture: texture)
            shot = Shot(node: node, position: start, velocity: velocity, life: Constants.shotLife, damage: damage, targetId: targetId)
        }

        node.removeAllActions()
        node.setScale(1)
        node.alpha = 1
        node.color = .white
        node.colorBlendFactor = 0
        node.size = size
        node.position = baseToStage(start)
        node.zRotation = angle(for: aim)
        node.zPosition = ZLayer.projectile
        node.isHidden = false
        if let parent = node.parent, parent !== projectileNode {
            node.removeFromParent()
        }
        if node.parent == nil {
            projectileNode.addChild(node)
        }

        shot.reset(position: start, velocity: velocity, life: Constants.shotLife, damage: damage, targetId: targetId)
        return shot
    }

    private func recycleShot(_ shot: Shot) {
        shot.dead = true
        shot.node.removeAllActions()
        shot.node.removeFromParent()
        shot.node.alpha = 1
        shot.node.setScale(1)
        if shotPool.count < Constants.shotPoolLimit {
            shotPool.append(shot)
        }
    }

    private func dequeueSparkNode(radius: CGFloat, color: UIColor, position: CGPoint) -> SKSpriteNode {
        let dot = sparkPool.popLast() ?? SKSpriteNode(texture: sparkTexture)
        dot.name = Constants.sparkNodeName
        dot.removeAllActions()
        dot.texture = sparkTexture
        dot.setScale(1)
        dot.alpha = 1
        dot.color = color
        dot.colorBlendFactor = 1.0
        dot.size = CGSize(width: radius * 2, height: radius * 2)
        dot.position = position
        dot.zPosition = ZLayer.particles
        dot.isHidden = false
        if let parent = dot.parent, parent !== particleNode {
            dot.removeFromParent()
        }
        if dot.parent == nil {
            particleNode.addChild(dot)
        }
        return dot
    }

    private func recycleSparkNode(_ dot: SKSpriteNode?) {
        guard let dot else {
            return
        }
        dot.removeAllActions()
        dot.removeFromParent()
        dot.alpha = 1
        dot.setScale(1)
        dot.isHidden = true
        if sparkPool.count < Constants.sparkPoolLimit {
            sparkPool.append(dot)
        }
    }

    private func clearParticleChildrenForRun() {
        for child in particleNode.children {
            if let spark = child as? SKSpriteNode, spark.name == Constants.sparkNodeName {
                recycleSparkNode(spark)
            } else {
                child.removeAllActions()
                child.removeFromParent()
            }
        }
    }

    private func togglePause() {
        guard mode == .running || mode == .paused else {
            return
        }
        if mode == .running {
            mode = .paused
            pauseOverlay.isHidden = false
            closePauseSubmenus()
            restartConfirmVisible = false
            restartConfirmOverlay.isHidden = true
            joystickVector = .zero
            fireTouchIds.removeAll()
            clearScreenShake()
            updateJoystickVisual()
            resetTiltCalibrationFeedback()
            updatePauseToggleLabels()
            pauseBossWarningSFX()
            audio.playSFX(.pauseOpen)
            audio.pauseMusic()
            audio.stopAmbience()
        } else {
            mode = .running
            pauseOverlay.isHidden = true
            closePauseSubmenus()
            restartConfirmVisible = false
            restartConfirmOverlay.isHidden = true
            resetTiltCalibrationFeedback()
            audio.resumeMusic()
            if shouldPlayVeinAmbience() {
                audio.playAmbience()
            }
            resumeBossWarningSFXIfNeeded()
        }
    }

    private func showTiltCalibrationFeedback(success: Bool) {
        let text = success ? "CENTERED" : "NO TILT SIGNAL"
        let strokeColor = success
            ? UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 0.95)
            : UIColor(red: 1.0, green: 0.42, blue: 0.30, alpha: 0.96)
        let textColor = success
            ? UIColor(red: 1.0, green: 0.96, blue: 0.78, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.82, blue: 0.64, alpha: 1.0)

        tiltCalibrationToast.removeAction(forKey: Constants.tiltCalibrationToastActionKey)
        tiltCalibrationToastLabel?.text = text
        tiltCalibrationToastLabel?.fontColor = textColor
        tiltCalibrationToastFrame?.strokeColor = strokeColor
        tiltCalibrationToast.isHidden = false
        tiltCalibrationToast.alpha = 0
        tiltCalibrationToast.setScale(0.92)
        tiltCalibrationToast.run(.sequence([
            .group([
                .fadeIn(withDuration: 0.14),
                .scale(to: 1.0, duration: 0.14)
            ]),
            .wait(forDuration: 1.35),
            .group([
                .fadeOut(withDuration: 0.35),
                .scale(to: 1.04, duration: 0.35)
            ]),
            .run { [weak self] in
                self?.tiltCalibrationToast.isHidden = true
                self?.tiltCalibrationToast.setScale(1.0)
            }
        ]), withKey: Constants.tiltCalibrationToastActionKey)

        tiltCalibrateLabel?.removeAction(forKey: Constants.tiltCalibrateButtonResetActionKey)
        tiltCalibrateLabel?.text = success ? "Centered" : "Unavailable"
        tiltCalibrateLabel?.run(.sequence([
            .wait(forDuration: 1.1),
            .run { [weak self] in
                self?.tiltCalibrateLabel?.text = "Calibrate"
            }
        ]), withKey: Constants.tiltCalibrateButtonResetActionKey)
    }

    private func resetTiltCalibrationFeedback() {
        tiltCalibrationToast.removeAction(forKey: Constants.tiltCalibrationToastActionKey)
        tiltCalibrationToast.alpha = 0
        tiltCalibrationToast.isHidden = true
        tiltCalibrationToast.setScale(1.0)
        tiltCalibrateLabel?.removeAction(forKey: Constants.tiltCalibrateButtonResetActionKey)
        tiltCalibrateLabel?.text = "Calibrate"
    }

    private func endRun() {
        mode = .gameOver
        let finalRecord = currentRunRecord()
        lastRunWasBest = profileStore.recordRun(finalRecord)
        gameCenter.submit(record: finalRecord)
        if lastRunWasBest {
            haptics.play(.success)
        } else {
            haptics.play(.warning)
        }
        controlsNode.isHidden = true
        upgradeOverlay.isHidden = true
        levelCompleteOverlay.isHidden = true
        pauseOverlay.isHidden = true
        closePauseSubmenus()
        clearScreenShake()
        restartConfirmVisible = false
        restartConfirmOverlay.isHidden = true
        gameOverOverlay.isHidden = false
        updateGameOverOverlay()
        pendingMusicCue = .menu
        pendingMusicTimer = 0.65
        stopBossEncounterSFX()
        audio.stopMusic()
        audio.stopAmbience()
        audio.playSFX(.playerDeath)
    }

    private func currentRunRecord() -> RunRecord {
        RunRecord(
            score: score,
            level: level,
            sections: sectionsCleared,
            neutralizations: totalKills,
            bosses: bossesNeutralized,
            survivalTime: runTime,
            date: Date()
        )
    }

    private func updatePlayer(delta: TimeInterval) {
        updateTiltVector(delta: delta)
        var move = currentMovementVector()
        updateLateralSwimSFX(for: move)
        let shiftPressed = pressedKeys.contains(.keyboardLeftShift) || pressedKeys.contains(.keyboardRightShift)
        if shiftPressed && !dashInputHeld {
            triggerDash(input: move)
        }
        dashInputHeld = shiftPressed

        if player.dashTimer > 0 {
            player.dashTimer = max(0, player.dashTimer - delta)
        } else if vectorLength(move) > 0.001 {
            move = normalized(move)
            let target = CGVector(dx: move.dx * Constants.playerSpeed, dy: move.dy * Constants.playerSpeed)
            player.velocity = lerp(player.velocity, target, min(Constants.playerAccel * CGFloat(delta), 1))
            updateHorizontalFacing(from: move)
        } else {
            player.velocity = lerp(player.velocity, .zero, min(Constants.playerDrag * CGFloat(delta), 1))
        }

        updatePlayerWake(delta: delta)

        player.position.x += player.velocity.dx * CGFloat(delta)
        player.position.y += player.velocity.dy * CGFloat(delta)
        player.position.x = clamp(player.position.x, 60, Constants.baseSize.width - 90)
        player.position.y = clamp(player.position.y, 90, Constants.baseSize.height - 80)
        player.shootCooldown = max(0, player.shootCooldown - delta)
        player.dashCooldown = max(0, player.dashCooldown - delta)
        player.pulseCooldown = max(0, player.pulseCooldown - delta)
        player.invulnerable = max(0, player.invulnerable - delta)
        player.hurtTimer = max(0, player.hurtTimer - delta)

        if !fireTouchIds.isEmpty || pressedKeys.contains(.keyboardSpacebar) {
            fireAntibody(force: false)
        }

        guard let playerNode else {
            return
        }

        playerNode.position = baseToStage(player.position)
        playerNode.zRotation = -clamp(player.velocity.dy / 650, -0.35, 0.35)
        if let atlasTexture {
            let isDashing = player.dashTimer > 0 && dashRank > 0
            let frame = isDashing ? AtlasFrames.whiteCell[5] : AtlasFrames.whiteCell[abs(move.dx) > 0.05 ? 1 : 0]
            playerNode.texture = regionTexture(from: atlasTexture, frame: frame)
            playerNode.size = playerSpriteSize(for: frame, matchIdleHeight: isDashing)
        }
        let facingX = player.dashTimer > 0 ? lastFacing.dx : move.dx
        if facingX < -0.05 {
            playerNode.xScale = -abs(playerNode.xScale)
        } else if facingX > 0.05 {
            playerNode.xScale = abs(playerNode.xScale)
        }
        playerNode.alpha = player.hurtTimer > 0 && Int(player.hurtTimer * 22) % 2 == 0 ? 0.55 : 1.0
        playerNode.colorBlendFactor = player.dashTimer > 0 ? 0.45 : 0
        playerNode.color = UIColor(red: 0.72, green: 1.0, blue: 1.0, alpha: 1.0)
        updateAbilityControls()
    }

    private func updateSpawning(delta: TimeInterval) {
        guard levelClearTimer <= 0 else {
            return
        }

        let spawnScale = levelSpawnScale()
        let bossTriggerReached = activeMission.isEncounter && levelProgress() >= bossTriggerProgress
        var bossApproachClearActive = false
        if bossTriggerReached && !bossSpawned {
            bossApproachClearActive = updateBossWarning(delta: delta)
        }

        spawnEnemyTimer -= delta
        spawnRedTimer -= delta
        spawnPlateletTimer -= delta

        let canSpawnEncounterEnemies = !activeMission.isEncounter || (!bossSpawned && (!bossWarningStarted || !bossApproachClearActive))
        if canSpawnEncounterEnemies && spawnEnemyTimer <= 0 {
            if liveEnemyCount() < Constants.maxActiveEnemies {
                spawnEnemy()
            }
            spawnEnemyTimer = TimeInterval(CGFloat.random(in: 0.78...1.35) * spawnScale)
        }

        if spawnRedTimer <= 0 {
            if redCells.count < Constants.redCellMaxActive {
                spawnRedCell()
            }
            spawnRedTimer = TimeInterval.random(in: 0.42...0.86)
        }

        let plateletCount = activePlateletCount()
        let plateletTarget = plateletTargetCount()
        if plateletCount < plateletTarget {
            spawnPlateletTimer = min(spawnPlateletTimer, 0.35)
        }

        if (!bossWarningStarted || !bossApproachClearActive) && spawnPlateletTimer <= 0 {
            if plateletCount < plateletLimit() {
                spawnPlatelet()
                spawnPlateletTimer = activePlateletCount() < plateletTarget
                    ? TimeInterval.random(in: 0.45...0.85)
                    : nextPlateletSpawnDelay(spawnScale: spawnScale)
            } else {
                spawnPlateletTimer = TimeInterval.random(in: 0.9...1.45)
            }
        }
    }

    private func updateBossWarning(delta: TimeInterval) -> Bool {
        guard !bossSpawned else {
            return false
        }

        if !bossWarningStarted {
            bossWarningStarted = true
            bossWarningTimer = Constants.bossWarningDuration
            bossClearTimer = Constants.bossPreClearDuration
            pendingMusicCue = nil
            pendingMusicTimer = 0
            audio.stopMusic()
            audio.stopAmbience()
            audio.playSFX(.bossWarning)
            showBanner("Pathogen signal building")
        }

        bossWarningTimer = max(0, bossWarningTimer - delta)
        let clearActive = bossWarningTimer <= Constants.bossPreClearDuration
        if clearActive && bossClearTimer > 0 {
            bossClearTimer = max(0, bossClearTimer - delta)
            if bossClearTimer == 0 {
                softClearBoard()
                showBanner("Clear vessel lane")
            }
        }

        if bossWarningTimer == 0 {
            spawnBoss()
        }
        return clearActive
    }

    private func softClearBoard() {
        for enemy in enemies where enemy.kind != .boss {
            enemy.dead = true
            spawnSpark(at: enemy.position, color: UIColor(red: 0.65, green: 1.0, blue: 0.9, alpha: 1.0), count: 5)
        }
        for platelet in platelets {
            platelet.dead = true
            spawnSpark(at: platelet.position, color: UIColor(red: 1.0, green: 0.82, blue: 0.32, alpha: 1.0), count: 5)
        }
    }

    private func spawnBoss() {
        guard let bossKind = activeMission.bossKind,
              let profile = bossProfile(for: bossKind),
              !bossSpawned else {
            return
        }

        bossSpawned = true
        bossDefeated = false
        let difficulty = difficultyMultiplier()
        let hpScale = 1 + max(0, difficulty - 1) * 0.9
        let frame = profile.frames[0]
        let visualSize = CGSize(width: frame.rect.width * profile.visualScale, height: frame.rect.height * profile.visualScale)
        let position = CGPoint(
            x: offscreenRightSpawnX(forVisualWidth: visualSize.width, grace: 64),
            y: Constants.baseSize.height * 0.48
        )
        let node = SKSpriteNode(texture: regionTexture(from: profile.texture, frame: frame))
        node.size = visualSize
        node.position = baseToStage(position)
        node.zPosition = ZLayer.entity + 3
        entityNode.addChild(node)

        let boss = Enemy(
            id: nextEnemyId,
            kind: .boss,
            node: node,
            position: position,
            velocity: CGVector(dx: -54, dy: 0),
            baseSpeed: 54,
            radius: profile.radius,
            hp: profile.hp * hpScale,
            score: Int(round(CGFloat(profile.score) * difficulty)),
            damage: profile.damage,
            bossKind: bossKind,
            damageScale: profile.damageScale,
            attackCooldown: profile.attackInterval * 0.75 / TimeInterval(sqrt(difficulty)),
            shieldCycle: TimeInterval.random(in: 0...1.2)
        )
        nextEnemyId += 1
        enemies.append(boss)
        showBanner(profile.title)
        stopBossEncounterSFX()
        audio.playMusic(.boss)
        audio.playAmbience()
    }

    private func seedRedCells() {
        let count = min(Constants.redCellMaxActive - 2, 6 + level)
        for _ in 0..<count {
            spawnRedCell(startOnScreen: true)
        }
    }

    private func seedPlatelets() {
        let count = plateletTargetCount()
        for _ in 0..<count {
            spawnPlatelet(startOnScreen: true)
        }
    }

    private func spawnRedCell(startOnScreen: Bool = false) {
        guard let atlasTexture else {
            return
        }
        let frame = AtlasFrames.redCell.randomElement() ?? AtlasFrames.redCell[0]
        let depth = CGFloat.random(in: 0.55...1.14)
        let radius = CGFloat.random(in: 24...46) * depth
        let visualScale = (radius * 1.86) / frame.rect.height
        let visualSize = CGSize(width: frame.rect.width * visualScale, height: frame.rect.height * visualScale)
        let offscreenSpawnX = offscreenRightSpawnX(forVisualWidth: visualSize.width, grace: 30)
        let xMin: CGFloat = startOnScreen ? 95 : offscreenSpawnX
        let xMax: CGFloat = startOnScreen ? Constants.baseSize.width + 180 : offscreenSpawnX + 170
        var position = CGPoint(
            x: CGFloat.random(in: xMin...xMax),
            y: CGFloat.random(in: (100 + radius)...(Constants.baseSize.height - 86 - radius))
        )
        if startOnScreen && distance(position, player.position) < 145 {
            position.x = min(Constants.baseSize.width + 120, position.x + 210)
        }

        let node = SKSpriteNode(texture: regionTexture(from: atlasTexture, frame: frame))
        node.size = visualSize
        node.position = baseToStage(position)
        node.alpha = depth >= 0.68 ? CGFloat.random(in: 0.68...0.84) : CGFloat.random(in: 0.38...0.58)
        node.zPosition = depth >= 0.68 ? ZLayer.entity + 1 : ZLayer.entity - 8
        entityNode.addChild(node)

        redCells.append(RedCell(
            node: node,
            position: position,
            radius: radius,
            depth: depth,
            speed: CGFloat.random(in: 46...116) * depth,
            drift: CGFloat.random(in: -14...14),
            rotation: CGFloat.random(in: 0...(CGFloat.pi * 2)),
            spin: CGFloat.random(in: -0.9...0.9),
            wobble: CGFloat.random(in: 0...(CGFloat.pi * 2))
        ))
    }

    private func spawnPlatelet(startOnScreen: Bool = false) {
        guard let atlasTexture else {
            return
        }
        let frame = AtlasFrames.platelet.randomElement() ?? AtlasFrames.platelet[0]
        let radius = CGFloat.random(in: 18...30)
        let visualScale = (radius * 2.55) / frame.rect.height
        let visualSize = CGSize(width: frame.rect.width * visualScale, height: frame.rect.height * visualScale)
        let offscreenSpawnX = offscreenRightSpawnX(forVisualWidth: visualSize.width, grace: 60)
        let xMin: CGFloat = startOnScreen ? Constants.baseSize.width * 0.55 : offscreenSpawnX
        let xMax: CGFloat = startOnScreen ? Constants.baseSize.width - 90 : offscreenSpawnX + 150
        var position = CGPoint(x: xMax, y: Constants.baseSize.height * 0.5)

        for attempt in 0..<8 {
            let candidate = CGPoint(
                x: CGFloat.random(in: xMin...xMax),
                y: CGFloat.random(in: (120 + radius)...(Constants.baseSize.height - 110 - radius))
            )
            var clear = !startOnScreen || distance(candidate, player.position) > 260
            for platelet in platelets where !platelet.dead {
                if distance(candidate, platelet.position) < radius + platelet.radius + 150 {
                    clear = false
                    break
                }
            }
            if clear || attempt == 7 {
                position = candidate
                break
            }
        }

        let node = SKSpriteNode(texture: regionTexture(from: atlasTexture, frame: frame))
        node.size = visualSize
        node.position = baseToStage(position)
        node.zPosition = ZLayer.entity + 2
        entityNode.addChild(node)

        platelets.append(Platelet(
            node: node,
            position: position,
            velocity: CGVector(dx: -CGFloat.random(in: 62...90), dy: 0),
            radius: radius,
            angle: CGFloat.random(in: 0...(CGFloat.pi * 2)),
            spin: CGFloat.random(in: -0.55...0.55)
        ))
    }

    private func spawnEnemy(kind requestedKind: EnemyKind? = nil, position requestedPosition: CGPoint? = nil, velocity requestedVelocity: CGVector? = nil) {
        guard let stats = enemyStats(for: requestedKind ?? pickEnemyKind()) else {
            return
        }
        let frame = stats.frames.randomElement() ?? stats.frames[0]
        var spawnY = CGFloat.random(in: 130...(Constants.baseSize.height - 115))
        if runTime < 10, abs(spawnY - player.position.y) < 135 {
            spawnY = spawnY < player.position.y ? max(130, spawnY - 150) : min(Constants.baseSize.height - 115, spawnY + 150)
        }
        let visualScale = stats.kind == .influenza && requestedPosition != nil ? 0.16 : (stats.radius * 2.9) / frame.rect.height
        let visualSize = CGSize(width: frame.rect.width * visualScale, height: frame.rect.height * visualScale)
        let position = requestedPosition ?? CGPoint(
            x: offscreenRightSpawnX(forVisualWidth: visualSize.width, grace: 50) + CGFloat.random(in: 0...170),
            y: spawnY
        )
        let texture = regionTexture(from: stats.texture, frame: frame)
        let node = SKSpriteNode(texture: texture)
        node.size = visualSize
        node.position = baseToStage(position)
        node.zPosition = ZLayer.entity
        entityNode.addChild(node)

        let velocity = requestedVelocity ?? CGVector(dx: -stats.speed, dy: CGFloat.random(in: -34...34))
        let enemy = Enemy(
            id: nextEnemyId,
            kind: stats.kind,
            node: node,
            position: position,
            velocity: velocity,
            baseSpeed: stats.speed,
            radius: stats.radius,
            hp: stats.hp,
            score: stats.score,
            damage: stats.damage,
            reproductionCooldown: stats.reproductionCooldown
        )
        nextEnemyId += 1
        enemies.append(enemy)
    }

    private func pickEnemyKind() -> EnemyKind {
        let roll = CGFloat.random(in: 0...1)
        let isInfluenzaBloom = level >= 4 && activeMission.name == "Influenza Bloom"
        var chosen: EnemyKind = .basic
        if level >= 4 && roll > (isInfluenzaBloom ? 0.28 : 0.84) {
            chosen = .influenza
        } else if roll > 0.88 && level > 3 {
            chosen = .budding
        } else if roll > 0.76 && level > 2 {
            chosen = .tank
        } else if roll > 0.52 {
            chosen = .fast
        }

        if chosen == .influenza && liveInfluenzaCount() >= influenzaCap() {
            chosen = level > 2 && roll > 0.62 ? .tank : .fast
        }
        return chosen
    }

    private func enemyStats(for kind: EnemyKind) -> EnemyStats? {
        guard let atlasTexture else {
            return nil
        }
        let difficulty = difficultyMultiplier()
        let levelPressure = max(0, difficultyPressureLevel() - 1)
        let levelBoost = min(12, levelPressure) * (1 + max(0, difficulty - 1) * 0.45)
        var hpBonusScale: CGFloat = 1.9
        let frames: [SpriteFrame]
        let texture: SKTexture
        let radius: CGFloat
        var hp: CGFloat
        var speed: CGFloat
        var score: Int
        let damage: CGFloat
        let reproductionCooldown: TimeInterval

        switch kind {
        case .basic:
            frames = AtlasFrames.greenVirus
            texture = atlasTexture
            radius = CGFloat.random(in: 18...25)
            hp = 2
            speed = CGFloat.random(in: 82...118) + levelBoost * 8
            score = 20
            damage = 14
            reproductionCooldown = 0
        case .fast:
            frames = AtlasFrames.purpleVirus
            texture = atlasTexture
            radius = CGFloat.random(in: 14...19)
            hp = 1
            speed = CGFloat.random(in: 135...178) + levelBoost * 10
            score = 30
            damage = 14
            hpBonusScale = 1.2
            reproductionCooldown = 0
        case .tank:
            frames = AtlasFrames.purpleVirus
            texture = atlasTexture
            radius = CGFloat.random(in: 28...36)
            hp = 4
            speed = CGFloat.random(in: 54...82) + levelBoost * 5
            score = 70
            damage = 22
            hpBonusScale = 2.8
            reproductionCooldown = 0
        case .budding:
            frames = AtlasFrames.greenVirus
            texture = atlasTexture
            radius = CGFloat.random(in: 22...29)
            hp = 3
            speed = CGFloat.random(in: 74...104) + levelBoost * 7
            score = 55
            damage = 14
            reproductionCooldown = 0
        case .influenza:
            guard let influenzaTexture else {
                return enemyStats(for: .tank)
            }
            frames = AtlasFrames.influenza
            texture = influenzaTexture
            radius = CGFloat.random(in: 23...31)
            hp = 3
            speed = CGFloat.random(in: 68...96) + levelBoost * 6
            score = 85
            damage = 16
            hpBonusScale = 2.2
            reproductionCooldown = TimeInterval.random(in: 0.25...0.85)
        case .fragment:
            frames = AtlasFrames.purpleVirus
            texture = atlasTexture
            radius = CGFloat.random(in: 10...14)
            hp = 1
            speed = CGFloat.random(in: 150...205) + min(8, CGFloat(level - 1)) * 8
            score = 15
            damage = 6
            reproductionCooldown = 0
        case .bossDecoy, .boss:
            return nil
        }

        if difficulty > 1 {
            let hpBonus = floor(max(0, difficulty - 1) * hpBonusScale)
            hp += hpBonus
            speed *= 1 + max(0, difficulty - 1) * 0.22
            score += Int(hpBonus) * 12
        }

        return EnemyStats(
            kind: kind,
            frames: frames,
            texture: texture,
            radius: radius,
            hp: hp,
            speed: speed,
            score: score,
            damage: damage,
            reproductionCooldown: reproductionCooldown
        )
    }

    private func updateEnemies(delta: TimeInterval) {
        var influenzaCloneRequests: [(position: CGPoint, velocity: CGVector)] = []

        for enemy in enemies where !enemy.dead {
            if enemy.kind == .boss {
                updateBoss(enemy, delta: delta)
            } else if enemy.kind == .bossDecoy {
                updateNorovirusDecoy(enemy, delta: delta)
            } else {
                let toPlayer = normalized(CGVector(dx: player.position.x - enemy.position.x, dy: player.position.y - enemy.position.y))
                let desired = CGVector(dx: -enemy.baseSpeed, dy: toPlayer.dy * 86)
                enemy.velocity = lerp(enemy.velocity, desired, min(CGFloat(delta) * 0.8, 1))
                enemy.position.x += enemy.velocity.dx * CGFloat(delta)
                enemy.position.y += enemy.velocity.dy * CGFloat(delta)
                enemy.reproductionCooldown = max(0, enemy.reproductionCooldown - delta)
                if enemy.kind == .influenza {
                    influenzaCloneRequests.append(contentsOf: checkInfluenzaReplication(for: enemy))
                }
            }
            enemy.node.position = baseToStage(enemy.position)
            enemy.node.zRotation += CGFloat(delta) * (enemy.kind == .boss ? 0.18 : (enemy.kind == .tank ? 0.36 : 0.7))
            if enemy.position.x < offscreenLeftRemovalX(for: enemy.node, grace: 28) {
                enemy.dead = true
            }
        }

        for request in influenzaCloneRequests where liveEnemyCount() < Constants.maxActiveEnemies + 8 {
            spawnEnemy(kind: .influenza, position: request.position, velocity: request.velocity)
            enemies.last?.hp = 2.8
            enemies.last?.maxHP = 2.8
            enemies.last?.score = 35
            enemies.last?.reproductionCooldown = 1.1
        }

        enemies.removeAll { enemy in
            if enemy.dead && !enemy.deathAnimationActive {
                enemy.node.removeFromParent()
                return true
            }
            return false
        }
    }

    private func updateBoss(_ enemy: Enemy, delta: TimeInterval) {
        guard let bossKind = enemy.bossKind, let profile = bossProfile(for: bossKind) else {
            return
        }

        let desiredX = Constants.baseSize.width * profile.targetX
        let centerY = Constants.baseSize.height * 0.5
        let driftAmplitude: CGFloat
        let driftRate: CGFloat
        switch bossKind {
        case .pox:
            driftAmplitude = 78
            driftRate = 0.95
        case .adenovirus:
            driftAmplitude = 92
            driftRate = 0.95
        case .filovirus:
            driftAmplitude = 112
            driftRate = 1.15
        case .rotavirus:
            driftAmplitude = 70
            driftRate = 0.82
        case .lyssavirus:
            driftAmplitude = 86
            driftRate = 1.02
        case .norovirus:
            driftAmplitude = 92
            driftRate = 0.9
        }

        let drift = sin(CGFloat(runTime) * driftRate + CGFloat(enemy.id)) * driftAmplitude
        enemy.position.x = CGFloat.lerp(from: enemy.position.x, to: desiredX, amount: min(CGFloat(delta) * 1.25, 0.08))
        enemy.position.y = clamp(centerY + drift, 105 + enemy.radius, Constants.baseSize.height - 95 - enemy.radius)
        enemy.attackCooldown -= delta

        switch bossKind {
        case .pox:
            updatePoxBoss(enemy, profile: profile)
        case .adenovirus:
            updateAdenovirusBoss(enemy, profile: profile, delta: delta)
        case .filovirus:
            updateFilovirusBoss(enemy, profile: profile)
        case .rotavirus:
            updateRotavirusBoss(enemy, profile: profile, delta: delta)
        case .lyssavirus:
            updateLyssavirusBoss(enemy, profile: profile, delta: delta)
        case .norovirus:
            updateNorovirusBoss(enemy, profile: profile, delta: delta)
        }
    }

    private func updatePoxBoss(_ enemy: Enemy, profile: BossProfile) {
        let healthRatio = clamp(enemy.hp / max(1, enemy.maxHP), 0, 1)
        var nextPhase = 0
        if healthRatio <= 0.22 {
            nextPhase = 3
        } else if healthRatio <= 0.48 {
            nextPhase = 2
        } else if healthRatio <= 0.72 {
            nextPhase = 1
        }

        if nextPhase > enemy.phase {
            enemy.phase = nextPhase
            spawnBossFragment(from: enemy, direction: -1)
            spawnBossFragment(from: enemy, direction: 1)
            audio.playSFX(.bossPhase)
            showBanner(nextPhase == 3 ? "Pox core exposed" : "Pox armor plates broke loose")
        }

        setBossTexture(enemy, profile: profile, frameIndex: enemy.phase)
        if enemy.attackCooldown <= 0 {
            let difficulty = difficultyMultiplier()
            enemy.attackCooldown = (profile.attackInterval + TimeInterval.random(in: -0.25...0.45)) / TimeInterval(sqrt(difficulty))
            spawnBossAdd(from: enemy, kind: .budding, angle: -0.8, speed: CGFloat.random(in: 84...112))
            spawnBossAdd(from: enemy, kind: .budding, angle: 0.8, speed: CGFloat.random(in: 84...112))
            audio.playSFX(.buddingSplit)
        }
    }

    private func updateAdenovirusBoss(_ enemy: Enemy, profile: BossProfile, delta: TimeInterval) {
        enemy.shieldCycle = (enemy.shieldCycle + delta).truncatingRemainder(dividingBy: 3.4)
        enemy.shieldOpen = enemy.shieldCycle > 2.12 && enemy.shieldCycle < 3.02
        let frameIndex = enemy.shieldOpen ? 2 : (enemy.shieldCycle > 1.2 ? 1 : 0)
        setBossTexture(enemy, profile: profile, frameIndex: frameIndex)
        enemy.node.colorBlendFactor = enemy.shieldOpen ? 0 : 0.28
        enemy.node.color = UIColor(red: 0.72, green: 0.96, blue: 1.0, alpha: 1.0)

        if enemy.attackCooldown <= 0 {
            let difficulty = difficultyMultiplier()
            enemy.attackCooldown = (profile.attackInterval + TimeInterval.random(in: -0.2...0.32)) / TimeInterval(sqrt(difficulty))
            setBossTexture(enemy, profile: profile, frameIndex: 3)
            for _ in 0..<3 {
                spawnBossAdd(from: enemy, kind: .fast, angle: CGFloat.random(in: -1...1), speed: CGFloat.random(in: 125...168))
            }
            audio.playSFX(.bossPhase)
        }
    }

    private func updateFilovirusBoss(_ enemy: Enemy, profile: BossProfile) {
        let frameIndex = Int(floor(runTime * 1.35)).positiveModulo(profile.frames.count)
        setBossTexture(enemy, profile: profile, frameIndex: frameIndex)
        if enemy.attackCooldown <= 0 {
            let difficulty = difficultyMultiplier()
            enemy.attackCooldown = (profile.attackInterval + TimeInterval.random(in: -0.25...0.55)) / TimeInterval(sqrt(difficulty))
            let lane: CGFloat = sin(CGFloat(runTime) * 1.7) > 0 ? 1 : -1
            spawnBossAdd(from: enemy, kind: .fast, angle: lane * 0.7, speed: CGFloat.random(in: 138...178))
            spawnBossAdd(from: enemy, kind: .tank, angle: -lane * 0.55, speed: CGFloat.random(in: 70...92))
            audio.playSFX(.bossPhase)
        }
    }

    private func updateRotavirusBoss(_ enemy: Enemy, profile: BossProfile, delta: TimeInterval) {
        let healthRatio = clamp(enemy.hp / max(1, enemy.maxHP), 0, 1)
        var nextPhase = 0
        if healthRatio <= 0.22 {
            nextPhase = 3
        } else if healthRatio <= 0.48 {
            nextPhase = 2
        } else if healthRatio <= 0.70 {
            nextPhase = 1
        }

        if nextPhase > enemy.phase {
            enemy.phase = nextPhase
            enemy.orbitDirection *= -1
            audio.playSFX(.bossPhase)
            showBanner(nextPhase == 3 ? "Rotavirus spin reversed" : "Rotavirus capsid tightened")
        }

        let cycleDuration = TimeInterval(max(2.25, 3.18 - CGFloat(enemy.phase) * 0.28))
        enemy.shieldCycle += delta * TimeInterval(1 + CGFloat(enemy.phase) * 0.10)
        while enemy.shieldCycle >= cycleDuration {
            enemy.shieldCycle -= cycleDuration
        }

        let openStart = cycleDuration * (enemy.phase >= 2 ? 0.50 : 0.56)
        let openEnd = cycleDuration * (enemy.phase >= 3 ? 0.78 : 0.86)
        enemy.shieldOpen = enemy.shieldCycle >= openStart && enemy.shieldCycle <= openEnd

        let spinDirection = enemy.orbitDirection == 0 ? 1 : enemy.orbitDirection
        enemy.node.zRotation += CGFloat(delta) * spinDirection * (0.55 + CGFloat(enemy.phase) * 0.24)
        enemy.node.color = UIColor(red: 0.68, green: 1.0, blue: 1.0, alpha: 1.0)
        enemy.node.colorBlendFactor = enemy.shieldOpen ? 0.04 : 0.26

        let frameIndex: Int
        if enemy.attackCooldown <= 0.20 {
            frameIndex = 4
        } else if healthRatio <= 0.16 {
            frameIndex = 6
        } else if enemy.shieldOpen {
            frameIndex = Int(floor(runTime * 2.0)).positiveModulo(3)
        } else {
            frameIndex = 3
        }
        setBossTexture(enemy, profile: profile, frameIndex: frameIndex)

        if enemy.attackCooldown <= 0 {
            let difficulty = difficultyMultiplier()
            let pressure = 1 + CGFloat(enemy.phase) * 0.10
            enemy.attackCooldown = (profile.attackInterval + TimeInterval.random(in: -0.18...0.34)) / TimeInterval(sqrt(difficulty) * pressure)
            spawnRotavirusSpokePulse(from: enemy)
            audio.playSFX(.bossPhase)
        }
    }

    private func updateLyssavirusBoss(_ enemy: Enemy, profile: BossProfile, delta: TimeInterval) {
        let desiredX = Constants.baseSize.width * profile.targetX
        let healthRatio = clamp(enemy.hp / max(1, enemy.maxHP), 0, 1)
        enemy.shieldOpen = enemy.phase == 3

        switch enemy.phase {
        case 0:
            let trackY = clamp(player.position.y + sin(CGFloat(runTime) * 1.1 + CGFloat(enemy.id)) * 22, 105 + enemy.radius, Constants.baseSize.height - 95 - enemy.radius)
            enemy.position.x = CGFloat.lerp(from: enemy.position.x, to: desiredX, amount: min(CGFloat(delta) * 1.5, 0.10))
            enemy.position.y = CGFloat.lerp(from: enemy.position.y, to: trackY, amount: min(CGFloat(delta) * 1.9, 0.12))
            enemy.node.colorBlendFactor = 0
            setBossTexture(enemy, profile: profile, frameIndex: Int(floor(runTime * 1.5)).positiveModulo(3))

            if enemy.attackCooldown <= 0 {
                enemy.phase = 1
                enemy.bossComboStep = 0
                enemy.bossTrailTimer = 0
                enemy.bossActionTimer = healthRatio <= 0.32 ? 0.54 : 0.74
                lockLyssavirusTarget(for: enemy, desiredX: desiredX)
                showLyssavirusTelegraphLine(y: enemy.bossTargetY)
                audio.playSFX(.bossWarning)
                haptics.play(.warning)
            }

        case 1:
            enemy.bossActionTimer = max(0, enemy.bossActionTimer - delta)
            lockLyssavirusTarget(for: enemy, desiredX: desiredX)
            enemy.position.x = CGFloat.lerp(from: enemy.position.x, to: desiredX, amount: min(CGFloat(delta) * 2.0, 0.16))
            enemy.position.y = CGFloat.lerp(from: enemy.position.y, to: enemy.bossTargetY, amount: min(CGFloat(delta) * 2.6, 0.20))
            let pulse = 0.36 + 0.18 * sin(CGFloat(runTime) * 22)
            enemy.node.color = UIColor(red: 0.40, green: 1.0, blue: 0.94, alpha: 1.0)
            enemy.node.colorBlendFactor = pulse
            setBossTexture(enemy, profile: profile, frameIndex: 3)

            if enemy.bossActionTimer == 0 {
                enemy.phase = 2
                enemy.bossActionTimer = healthRatio <= 0.45 ? 0.86 : 0.78
                enemy.orbitDirection = CGFloat.random(in: 0...1) < 0.5 ? -1 : 1
                setLyssavirusChargeVector(for: enemy)
                showLyssavirusTelegraphLine(y: enemy.bossTargetY)
                setBossTexture(enemy, profile: profile, frameIndex: 4)
                audio.playSFX(.bossPhase)
            }

        case 2:
            enemy.bossActionTimer = max(0, enemy.bossActionTimer - delta)
            let difficulty = difficultyMultiplier()
            let chargeSpeed = (healthRatio <= 0.32 ? CGFloat(920) : CGFloat(820)) * (1 + max(0, difficulty - 1) * 0.12)
            steerLyssavirusChargeTowardPlayer(for: enemy, desiredX: desiredX, delta: delta, turnRate: healthRatio <= 0.32 ? 4.2 : 3.1)
            enemy.position.x += enemy.velocity.dx * chargeSpeed * CGFloat(delta)
            enemy.position.y += enemy.velocity.dy * chargeSpeed * CGFloat(delta)
            enemy.position.y = clamp(enemy.position.y, 105 + enemy.radius, Constants.baseSize.height - 95 - enemy.radius)
            enemy.node.color = UIColor(red: 0.55, green: 1.0, blue: 0.94, alpha: 1.0)
            enemy.node.colorBlendFactor = 0.34
            setBossTexture(enemy, profile: profile, frameIndex: 4)
            if healthRatio <= 0.55 {
                enemy.bossTrailTimer = max(0, enemy.bossTrailTimer - delta)
                if enemy.bossTrailTimer == 0 {
                    spawnLyssavirusTrailHazard(from: enemy, intensity: healthRatio <= 0.28 ? 1.22 : 1.0)
                    enemy.bossTrailTimer = healthRatio <= 0.28 ? 0.13 : 0.18
                }
            }

            let targetPoint = CGPoint(x: enemy.bossTargetX, y: enemy.bossTargetY)
            if enemy.position.x <= visibleBaseMinX() + 185 || enemy.bossActionTimer == 0 || distance(enemy.position, targetPoint) < 34 {
                enemy.phase = 3
                enemy.bossActionTimer = healthRatio <= 0.25 ? 0.58 : 0.74
                enemy.attackCooldown = profile.attackInterval / TimeInterval(sqrt(difficulty))
                setBossTexture(enemy, profile: profile, frameIndex: 5)
                showBanner("Lyssavirus exposed")
            }

        case 3:
            enemy.bossActionTimer = max(0, enemy.bossActionTimer - delta)
            let recoverY = clamp(Constants.baseSize.height * 0.5 + sin(CGFloat(runTime) * 1.4 + CGFloat(enemy.id)) * 58, 105 + enemy.radius, Constants.baseSize.height - 95 - enemy.radius)
            let returnSpeed: CGFloat = healthRatio <= 0.55 ? 2.45 : 1.85
            enemy.position.x = CGFloat.lerp(from: enemy.position.x, to: desiredX, amount: min(CGFloat(delta) * returnSpeed, healthRatio <= 0.55 ? 0.18 : 0.13))
            enemy.position.y = CGFloat.lerp(from: enemy.position.y, to: recoverY, amount: min(CGFloat(delta) * 1.7, 0.12))
            enemy.node.color = UIColor(red: 0.70, green: 1.0, blue: 0.92, alpha: 1.0)
            enemy.node.colorBlendFactor = 0.18
            setBossTexture(enemy, profile: profile, frameIndex: healthRatio <= 0.22 ? 6 : 5)
            if healthRatio <= 0.55 {
                enemy.bossTrailTimer = max(0, enemy.bossTrailTimer - delta)
                if enemy.bossTrailTimer == 0 {
                    spawnLyssavirusTrailHazard(from: enemy, intensity: healthRatio <= 0.28 ? 1.16 : 0.92)
                    enemy.bossTrailTimer = 0.22
                }
            }

            if enemy.bossActionTimer == 0 {
                if healthRatio <= 0.36 && enemy.bossComboStep == 0 {
                    enemy.phase = 4
                    enemy.bossComboStep = 1
                    enemy.bossActionTimer = 0.42
                    lockLyssavirusTarget(for: enemy, desiredX: desiredX)
                    showLyssavirusTelegraphLine(y: enemy.bossTargetY)
                    audio.playSFX(.bossWarning)
                } else {
                    enemy.phase = 0
                    enemy.node.colorBlendFactor = 0
                    enemy.attackCooldown = max(enemy.attackCooldown, 0.42)
                }
            }

        case 4:
            enemy.bossActionTimer = max(0, enemy.bossActionTimer - delta)
            lockLyssavirusTarget(for: enemy, desiredX: desiredX)
            enemy.position.x = CGFloat.lerp(from: enemy.position.x, to: desiredX, amount: min(CGFloat(delta) * 2.5, 0.22))
            enemy.position.y = CGFloat.lerp(from: enemy.position.y, to: enemy.bossTargetY, amount: min(CGFloat(delta) * 4.0, 0.34))
            let pulse = 0.48 + 0.20 * sin(CGFloat(runTime) * 28)
            enemy.node.color = UIColor(red: 0.45, green: 1.0, blue: 0.92, alpha: 1.0)
            enemy.node.colorBlendFactor = pulse
            setBossTexture(enemy, profile: profile, frameIndex: 3)

            if enemy.bossActionTimer == 0 {
                enemy.phase = 5
                enemy.bossActionTimer = 0.38
                enemy.bossTrailTimer = 0
                setLyssavirusChargeVector(for: enemy)
                showLyssavirusTelegraphLine(y: enemy.bossTargetY)
                setBossTexture(enemy, profile: profile, frameIndex: 4)
                audio.playSFX(.bossPhase)
            }

        case 5:
            enemy.bossActionTimer = max(0, enemy.bossActionTimer - delta)
            let difficulty = difficultyMultiplier()
            let chargeSpeed = CGFloat(980) * (1 + max(0, difficulty - 1) * 0.12)
            steerLyssavirusChargeTowardPlayer(for: enemy, desiredX: desiredX, delta: delta, turnRate: 5.0)
            enemy.position.x += enemy.velocity.dx * chargeSpeed * CGFloat(delta)
            enemy.position.y += enemy.velocity.dy * chargeSpeed * CGFloat(delta)
            enemy.position.y = clamp(enemy.position.y, 105 + enemy.radius, Constants.baseSize.height - 95 - enemy.radius)
            enemy.node.color = UIColor(red: 0.50, green: 1.0, blue: 0.92, alpha: 1.0)
            enemy.node.colorBlendFactor = 0.40
            setBossTexture(enemy, profile: profile, frameIndex: 4)
            enemy.bossTrailTimer = max(0, enemy.bossTrailTimer - delta)
            if enemy.bossTrailTimer == 0 {
                spawnLyssavirusTrailHazard(from: enemy, intensity: 1.28)
                enemy.bossTrailTimer = 0.11
            }

            let targetPoint = CGPoint(x: enemy.bossTargetX, y: enemy.bossTargetY)
            if enemy.position.x <= visibleBaseMinX() + 360 || enemy.bossActionTimer == 0 || distance(enemy.position, targetPoint) < 34 {
                enemy.phase = 3
                enemy.bossActionTimer = 0.40
                enemy.attackCooldown = profile.attackInterval * 0.84 / TimeInterval(sqrt(difficulty))
                setBossTexture(enemy, profile: profile, frameIndex: 5)
                showBanner("Lyssavirus exposed")
            }

        default:
            enemy.phase = 0
            enemy.node.colorBlendFactor = 0
            enemy.attackCooldown = max(enemy.attackCooldown, 0.42)
        }
    }

    private func lockLyssavirusTarget(for enemy: Enemy, desiredX: CGFloat) {
        let minimumX = visibleBaseMinX() + 110
        let maximumX = max(minimumX + 80, desiredX - 150)
        enemy.bossTargetX = clamp(player.position.x, minimumX, maximumX)
        enemy.bossTargetY = clamp(player.position.y, 116 + enemy.radius, Constants.baseSize.height - 112 - enemy.radius)
    }

    private func setLyssavirusChargeVector(for enemy: Enemy) {
        let targetPoint = CGPoint(x: enemy.bossTargetX, y: enemy.bossTargetY)
        var aim = normalized(CGVector(dx: targetPoint.x - enemy.position.x, dy: targetPoint.y - enemy.position.y))
        if vectorLength(aim) <= 0.001 {
            aim = CGVector(dx: -1, dy: 0)
        }
        enemy.velocity = aim
    }

    private func steerLyssavirusChargeTowardPlayer(for enemy: Enemy, desiredX: CGFloat, delta: TimeInterval, turnRate: CGFloat) {
        let minimumX = visibleBaseMinX() + 110
        let maximumX = max(minimumX + 80, desiredX - 150)
        enemy.bossTargetX = clamp(player.position.x, minimumX, maximumX)
        enemy.bossTargetY = clamp(player.position.y, 116 + enemy.radius, Constants.baseSize.height - 112 - enemy.radius)
        let targetPoint = CGPoint(x: enemy.bossTargetX, y: enemy.bossTargetY)
        let desiredAim = normalized(CGVector(dx: targetPoint.x - enemy.position.x, dy: targetPoint.y - enemy.position.y))
        guard vectorLength(desiredAim) > 0.001 else { return }

        let amount = min(CGFloat(delta) * turnRate, 0.14)
        let blended = normalized(CGVector(
            dx: enemy.velocity.dx + (desiredAim.dx - enemy.velocity.dx) * amount,
            dy: enemy.velocity.dy + (desiredAim.dy - enemy.velocity.dy) * amount
        ))
        if vectorLength(blended) > 0.001 {
            enemy.velocity = blended
        }
    }

    private func updateNorovirusBoss(_ enemy: Enemy, profile: BossProfile, delta: TimeInterval) {
        let healthRatio = clamp(enemy.hp / max(1, enemy.maxHP), 0, 1)
        var nextPhase = 0
        if healthRatio <= 0.24 {
            nextPhase = 3
        } else if healthRatio <= 0.50 {
            nextPhase = 2
        } else if healthRatio <= 0.72 {
            nextPhase = 1
        }

        if nextPhase > enemy.phase {
            enemy.phase = nextPhase
            audio.playSFX(.bossPhase)
            showBanner(nextPhase == 3 ? "Norovirus decoys surged" : "Norovirus orbs multiplied")
        }

        let decoyCount = activeNorovirusDecoyCount()
        enemy.shieldOpen = decoyCount == 0
        enemy.node.color = UIColor(red: 0.82, green: 0.72, blue: 1.0, alpha: 1.0)
        enemy.node.colorBlendFactor = decoyCount > 0 ? 0.16 : 0
        let pulseFrame = decoyCount > 0 ? 3 + Int(floor(runTime * 2.0)).positiveModulo(2) : Int(floor(runTime * 1.35)).positiveModulo(3)
        setBossTexture(enemy, profile: profile, frameIndex: pulseFrame)

        if enemy.attackCooldown <= 0 && decoyCount < Constants.maxNorovirusDecoys {
            let difficulty = difficultyMultiplier()
            let requested = min(Constants.maxNorovirusDecoys, 4 + enemy.phase)
            spawnNorovirusDecoys(from: enemy, requestedCount: requested - decoyCount)
            let pressureScale = healthRatio <= 0.26 ? 1.22 : (healthRatio <= 0.52 ? 1.12 : 1.0)
            enemy.attackCooldown = (profile.attackInterval + TimeInterval.random(in: -0.32...0.26)) / TimeInterval(sqrt(difficulty) * pressureScale)
            audio.playSFX(.bossPhase)
        }
    }

    private func updateNorovirusDecoy(_ enemy: Enemy, delta: TimeInterval) {
        guard let boss = activeBoss(), boss.bossKind == .norovirus, !boss.dead else {
            enemy.dead = true
            return
        }

        if enemy.bossActionTimer > 0 {
            enemy.bossActionTimer = max(0, enemy.bossActionTimer - delta)
            enemy.orbitAngle += CGFloat(delta) * enemy.orbitDirection * (2.0 + CGFloat(boss.phase) * 0.22)
            let radius = enemy.orbitRadius + sin(CGFloat(runTime) * 2.8 + CGFloat(enemy.id)) * 7
            let desired = CGPoint(
                x: boss.position.x + cos(enemy.orbitAngle) * radius,
                y: clamp(boss.position.y + sin(enemy.orbitAngle) * radius * 0.72, 110 + enemy.radius, Constants.baseSize.height - 100 - enemy.radius)
            )
            enemy.position.x = CGFloat.lerp(from: enemy.position.x, to: desired.x, amount: min(CGFloat(delta) * 7.0, 1))
            enemy.position.y = CGFloat.lerp(from: enemy.position.y, to: desired.y, amount: min(CGFloat(delta) * 7.0, 1))

            if enemy.bossActionTimer == 0 {
                enemy.phase = 1
                let difficulty = difficultyMultiplier()
                let driftSpeed = (CGFloat.random(in: 142...192) + CGFloat(boss.phase) * 22) * (1 + max(0, difficulty - 1) * 0.10)
                enemy.bossTargetX = player.position.x
                enemy.bossTargetY = player.position.y
                var aim = normalized(CGVector(dx: enemy.bossTargetX - enemy.position.x, dy: enemy.bossTargetY - enemy.position.y))
                if vectorLength(aim) <= 0.001 {
                    aim = CGVector(dx: -1, dy: 0)
                }
                enemy.velocity = CGVector(dx: aim.dx * driftSpeed, dy: aim.dy * driftSpeed)
                enemy.bossTrailTimer = 0
            }
        } else {
            enemy.position.x += enemy.velocity.dx * CGFloat(delta)
            enemy.position.y += enemy.velocity.dy * CGFloat(delta)
            enemy.position.y = clamp(enemy.position.y, 90 + enemy.radius, Constants.baseSize.height - 85 - enemy.radius)
            enemy.bossTrailTimer = max(0, enemy.bossTrailTimer - delta)
            if enemy.bossTrailTimer == 0 {
                spawnSpark(at: enemy.position, color: UIColor(red: 0.58, green: 0.95, blue: 1.0, alpha: 1.0), count: 2)
                enemy.bossTrailTimer = 0.13
            }
        }

        enemy.node.alpha = enemy.bossActionTimer > 0 ? 0.96 : 0.88
        enemy.node.setScale(enemy.bossActionTimer > 0 ? 1.0 : 0.92)
    }

    private func setBossTexture(_ enemy: Enemy, profile: BossProfile, frameIndex: Int) {
        let frame = profile.frames[frameIndex.clamped(to: 0...(profile.frames.count - 1))]
        enemy.node.texture = regionTexture(from: profile.texture, frame: frame)
    }

    private func beginBossDeathAnimation(_ enemy: Enemy) {
        guard let bossKind = enemy.bossKind, let profile = bossProfile(for: bossKind) else {
            spawnSpark(at: enemy.position, color: UIColor(red: 0.5, green: 1.0, blue: 0.88, alpha: 1.0), count: 18)
            return
        }

        let color = bossDeathBurstColor(for: bossKind)
        let position = enemy.position
        let radius = enemy.radius
        let secondaryBursts = [
            CGPoint(x: position.x - radius * 0.34, y: clamp(position.y - radius * 0.24, 95 + radius * 0.25, Constants.baseSize.height - 90 - radius * 0.25)),
            CGPoint(x: position.x + radius * 0.24, y: clamp(position.y + radius * 0.28, 95 + radius * 0.25, Constants.baseSize.height - 90 - radius * 0.25)),
            CGPoint(x: position.x - radius * 0.06, y: clamp(position.y + radius * 0.04, 95 + radius * 0.25, Constants.baseSize.height - 90 - radius * 0.25))
        ]

        enemy.deathAnimationActive = true
        enemy.node.removeAllActions()
        enemy.node.zPosition = ZLayer.entity + 7
        enemy.node.alpha = 1
        enemy.node.setScale(1)
        enemy.node.color = UIColor.white
        enemy.node.colorBlendFactor = 0
        setBossTexture(enemy, profile: profile, frameIndex: profile.frames.count - 1)

        spawnBossDeathBurst(at: position, color: color, count: 16, shockwaveRadius: radius * 1.25)
        enemy.node.run(.sequence([
            .group([
                .scale(to: 1.08, duration: 0.16),
                .colorize(with: color, colorBlendFactor: 0.42, duration: 0.16),
                .rotate(byAngle: bossKind == .filovirus ? 0.18 : -0.12, duration: 0.16)
            ]),
            .wait(forDuration: 0.12),
            .run { [weak self] in
                self?.spawnBossDeathBurst(at: secondaryBursts[0], color: color, count: 12, shockwaveRadius: radius * 0.72)
            },
            .wait(forDuration: 0.16),
            .run { [weak self] in
                self?.spawnBossDeathBurst(at: secondaryBursts[1], color: color, count: 12, shockwaveRadius: radius * 0.82)
                self?.addScreenShake(duration: 0.18, magnitude: 10)
            },
            .wait(forDuration: 0.12),
            .run { [weak self] in
                self?.spawnBossDeathBurst(at: secondaryBursts[2], color: UIColor.white, count: 8, shockwaveRadius: radius * 0.55)
            },
            .group([
                .fadeOut(withDuration: 0.34),
                .scale(to: 0.18, duration: 0.34),
                .rotate(byAngle: bossKind == .filovirus ? -0.32 : 0.28, duration: 0.34)
            ]),
            .run { [weak enemy] in
                enemy?.deathAnimationActive = false
                enemy?.node.removeFromParent()
            }
        ]))
    }

    private func bossDeathBurstColor(for bossKind: BossKind) -> UIColor {
        switch bossKind {
        case .pox:
            return UIColor(red: 0.94, green: 0.68, blue: 0.28, alpha: 1.0)
        case .adenovirus, .rotavirus:
            return UIColor(red: 0.38, green: 1.0, blue: 0.94, alpha: 1.0)
        case .filovirus:
            return UIColor(red: 0.72, green: 1.0, blue: 0.48, alpha: 1.0)
        case .lyssavirus:
            return UIColor(red: 0.42, green: 1.0, blue: 0.92, alpha: 1.0)
        case .norovirus:
            return UIColor(red: 0.86, green: 0.36, blue: 1.0, alpha: 1.0)
        }
    }

    private func spawnBossDeathBurst(at basePosition: CGPoint, color: UIColor, count: Int, shockwaveRadius: CGFloat) {
        spawnBossDeathShockwave(at: basePosition, color: color, radius: shockwaveRadius)
        spawnSpark(at: basePosition, color: color, count: count)
    }

    private func spawnBossDeathShockwave(at basePosition: CGPoint, color: UIColor, radius: CGFloat) {
        guard reserveCosmeticNode() else {
            return
        }

        let ring = SKShapeNode(circleOfRadius: max(14, radius * 0.38))
        ring.position = baseToStage(basePosition)
        ring.strokeColor = color.withAlphaComponent(0.78)
        ring.fillColor = .clear
        ring.lineWidth = 5
        ring.glowWidth = 10
        ring.alpha = 0.95
        ring.zPosition = ZLayer.particles + 6
        particleNode.addChild(ring)
        ring.run(.sequence([
            .group([
                .scale(to: 2.25, duration: 0.38),
                .fadeOut(withDuration: 0.38)
            ]),
            .removeFromParent()
        ]))
    }

    private func spawnBossAdd(from boss: Enemy, kind: EnemyKind, angle: CGFloat, speed: CGFloat) {
        let y = clamp(boss.position.y + sin(angle) * boss.radius * 0.95, 120, Constants.baseSize.height - 110)
        let position = CGPoint(x: boss.position.x - boss.radius * 0.55, y: y)
        let difficulty = difficultyMultiplier()
        let velocity = CGVector(
            dx: -speed * (1 + max(0, difficulty - 1) * 0.16),
            dy: sin(angle) * CGFloat.random(in: 34...58)
        )
        spawnEnemy(kind: kind, position: position, velocity: velocity)
    }

    private func spawnBossFragment(from boss: Enemy, direction: Int) {
        let position = CGPoint(
            x: boss.position.x + CGFloat.random(in: 10...22),
            y: clamp(boss.position.y + CGFloat(direction) * CGFloat.random(in: 24...46), 120, Constants.baseSize.height - 110)
        )
        spawnEnemy(
            kind: .fragment,
            position: position,
            velocity: CGVector(dx: -CGFloat.random(in: 150...205), dy: CGFloat(direction) * CGFloat.random(in: 36...72))
        )
    }

    private func spawnRotavirusSpokePulse(from boss: Enemy) {
        let availableSlots = max(0, Constants.maxActiveEnemies + 7 - liveEnemyCount())
        guard availableSlots > 0 else {
            return
        }

        let count = min(availableSlots, min(5, 3 + boss.phase))
        let baseAngle = CGFloat(boss.shieldCycle) * 2.35 * (boss.orbitDirection == 0 ? 1 : boss.orbitDirection)
        let difficulty = difficultyMultiplier()
        for index in 0..<count {
            let angle = baseAngle + CGFloat(index) * (CGFloat.pi * 2 / CGFloat(count))
            let spawnPosition = CGPoint(
                x: boss.position.x - boss.radius * 0.35 + cos(angle) * boss.radius * 0.20,
                y: clamp(boss.position.y + sin(angle) * boss.radius * 0.86, 115, Constants.baseSize.height - 105)
            )
            let speed = (CGFloat.random(in: 116...150) + CGFloat(boss.phase) * 14) * (1 + max(0, difficulty - 1) * 0.10)
            let velocity = CGVector(dx: -speed, dy: sin(angle) * CGFloat.random(in: 58...104))
            spawnEnemy(kind: .fragment, position: spawnPosition, velocity: velocity)
        }
        spawnSpark(at: boss.position, color: UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 1.0), count: 5)
    }

    private func showLyssavirusTelegraphLine(y targetY: CGFloat) {
        guard reserveCosmeticNode() else {
            return
        }

        let start = baseToStage(CGPoint(x: visibleBaseMinX() + 72, y: targetY))
        let end = baseToStage(CGPoint(x: visibleBaseMaxX() + 44, y: targetY))
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)

        let line = SKShapeNode(path: path)
        line.strokeColor = UIColor(red: 0.38, green: 1.0, blue: 0.92, alpha: 0.95)
        line.lineWidth = 8
        line.glowWidth = 14
        line.alpha = 0.95
        line.zPosition = ZLayer.particles + 8
        particleNode.addChild(line)
        line.run(.sequence([
            .group([
                .fadeOut(withDuration: 0.78),
                .scaleY(to: 1.28, duration: 0.78)
            ]),
            .removeFromParent()
        ]))
    }

    private func spawnLyssavirusTrailHazard(from boss: Enemy, intensity: CGFloat) {
        guard liveEnemyCount() < Constants.maxActiveEnemies + 8 else {
            return
        }

        let position = CGPoint(
            x: boss.position.x + boss.radius * CGFloat.random(in: 0.10...0.48),
            y: clamp(boss.position.y + CGFloat.random(in: -22...22), 112, Constants.baseSize.height - 104)
        )
        let speed = CGFloat.random(in: 112...154) * intensity
        spawnEnemy(
            kind: .fragment,
            position: position,
            velocity: CGVector(dx: -speed, dy: CGFloat.random(in: -48...48) * intensity)
        )
        if let hazard = enemies.last, hazard.kind == .fragment {
            hazard.damage = 5
            hazard.score = 8
            hazard.node.alpha = 0.82
            hazard.node.color = UIColor(red: 0.40, green: 1.0, blue: 0.90, alpha: 1.0)
            hazard.node.colorBlendFactor = 0.34
            spawnSpark(at: position, color: UIColor(red: 0.40, green: 1.0, blue: 0.90, alpha: 1.0), count: 2)
        }
    }

    private func activeNorovirusDecoyCount() -> Int {
        enemies.reduce(0) { count, enemy in
            count + (!enemy.dead && enemy.kind == .bossDecoy && enemy.bossKind == .norovirus ? 1 : 0)
        }
    }

    private func spawnNorovirusDecoys(from boss: Enemy, requestedCount: Int) {
        guard requestedCount > 0,
              let norovirusTexture else {
            return
        }

        let availableDecoys = max(0, Constants.maxNorovirusDecoys - activeNorovirusDecoyCount())
        let availableEnemySlots = max(0, Constants.maxActiveEnemies + 8 - liveEnemyCount())
        let count = min(requestedCount, availableDecoys, availableEnemySlots)
        guard count > 0 else {
            return
        }

        let frame = AtlasFrames.norovirusDecoyOrb
        let texture = regionTexture(from: norovirusTexture, frame: frame)
        let difficulty = difficultyMultiplier()
        for index in 0..<count {
            let angle = CGFloat(index) * (CGFloat.pi * 2 / CGFloat(count)) + CGFloat.random(in: -0.28...0.28) + CGFloat(runTime)
            let orbitRadius = CGFloat.random(in: 76...108) + CGFloat(boss.phase) * 7
            let position = CGPoint(
                x: boss.position.x + cos(angle) * orbitRadius,
                y: clamp(boss.position.y + sin(angle) * orbitRadius * 0.72, 112, Constants.baseSize.height - 104)
            )
            let node = SKSpriteNode(texture: texture)
            node.size = CGSize(width: frame.rect.width * 0.52, height: frame.rect.height * 0.52)
            node.position = baseToStage(position)
            node.zPosition = ZLayer.entity + 4
            entityNode.addChild(node)

            let decoy = Enemy(
                id: nextEnemyId,
                kind: .bossDecoy,
                node: node,
                position: position,
                velocity: .zero,
                baseSpeed: 104,
                radius: 17,
                hp: 1.15 + max(0, difficulty - 1) * 0.28,
                score: 18,
                damage: 8,
                bossKind: .norovirus,
                damageScale: 1,
                attackCooldown: 0,
                shieldCycle: 0
            )
            let orbitTime = CGFloat.random(in: 0.72...1.10) - CGFloat(boss.phase) * 0.08
            decoy.bossActionTimer = TimeInterval(max(0.46, orbitTime))
            decoy.orbitAngle = angle
            decoy.orbitRadius = orbitRadius
            decoy.orbitDirection = index.isMultiple(of: 2) ? 1 : -1
            nextEnemyId += 1
            enemies.append(decoy)
        }
        spawnSpark(at: boss.position, color: UIColor(red: 0.86, green: 0.36, blue: 1.0, alpha: 1.0), count: 5)
    }

    private func clearBossDecoys(for bossKind: BossKind?) {
        guard bossKind == .norovirus else {
            return
        }

        for decoy in enemies where decoy.kind == .bossDecoy && decoy.bossKind == .norovirus && !decoy.dead {
            decoy.dead = true
            spawnSpark(at: decoy.position, color: UIColor(red: 0.86, green: 0.36, blue: 1.0, alpha: 1.0), count: 4)
        }
    }

    private func checkInfluenzaReplication(for enemy: Enemy) -> [(position: CGPoint, velocity: CGVector)] {
        guard enemy.reproductionCooldown <= 0, liveEnemyCount() <= 46, liveInfluenzaCount() < influenzaCap() else {
            return []
        }

        guard let other = enemies.first(where: {
            $0 !== enemy &&
            !$0.dead &&
            $0.kind == .influenza &&
            $0.reproductionCooldown <= 0 &&
            distance($0.position, enemy.position) < $0.radius + enemy.radius
        }) else {
            return []
        }

        enemy.reproductionCooldown = 1.2
        other.reproductionCooldown = 1.2
        let midpoint = CGPoint(x: (enemy.position.x + other.position.x) * 0.5, y: (enemy.position.y + other.position.y) * 0.5)
        audio.playSFX(.influenzaReplicate)
        return (0..<2).map { _ in
            let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
            let pushSpeed = CGFloat.random(in: 90...150)
            let push = CGVector(dx: cos(angle) * pushSpeed, dy: sin(angle) * pushSpeed)
            let spawnPosition = CGPoint(
                x: midpoint.x + normalized(push).dx * 18,
                y: midpoint.y + normalized(push).dy * 18
            )
            return (
                position: spawnPosition,
                velocity: CGVector(dx: push.dx - 82, dy: push.dy + CGFloat.random(in: -20...20))
            )
        }
    }

    private func fireAntibody(force: Bool) {
        guard mode == .running, let atlasTexture, let playerNode else {
            return
        }

        let cooldown = antibodyCooldown()
        if !force, player.shootCooldown > 0 {
            return
        }
        if force, player.shootCooldown > cooldown * 0.65 {
            return
        }
        player.shootCooldown = cooldown

        let target = findLockTarget()
        lockTargetId = target?.id
        var aim = CGVector(dx: 1, dy: 0)
        if let target {
            aim = normalized(CGVector(dx: target.position.x - player.position.x, dy: target.position.y - player.position.y))
        }

        let shotCount = antibodyShotCount()
        let spreadStep = antibodySpreadStep()
        let frame = AtlasFrames.antibody[min(rapidRank, AtlasFrames.antibody.count - 1)]
        let textureIndex = min(rapidRank, antibodyTextures.count - 1)
        let texture = antibodyTextures.indices.contains(textureIndex) ? antibodyTextures[textureIndex] : regionTexture(from: atlasTexture, frame: frame)
        for index in 0..<shotCount {
            let offset = (CGFloat(index) - CGFloat(shotCount - 1) * 0.5) * spreadStep
            let shotAim = rotated(aim, radians: offset)
            let start = CGPoint(x: player.position.x + shotAim.dx * 46, y: player.position.y + shotAim.dy * 46)
            let velocity = CGVector(
                dx: shotAim.dx * Constants.shotSpeed + player.velocity.dx * 0.12,
                dy: shotAim.dy * Constants.shotSpeed + player.velocity.dy * 0.12
            )
            shots.append(dequeueShot(
                texture: texture,
                size: CGSize(width: frame.rect.width * 0.34, height: frame.rect.height * 0.34),
                start: start,
                aim: shotAim,
                velocity: velocity,
                damage: antibodyDamage(),
                targetId: target?.id
            ))
        }

        playerNode.xScale = aim.dx < -0.05 ? -abs(playerNode.xScale) : abs(playerNode.xScale)
        updateHorizontalFacing(from: aim)
        spawnSpark(at: CGPoint(x: player.position.x + aim.dx * 46, y: player.position.y + aim.dy * 46), color: UIColor(red: 0.72, green: 1.0, blue: 0.94, alpha: 1.0), count: 5)
        if shotSoundTimer <= 0 {
            audio.playSFX(.shot)
            shotSoundTimer = 0.035
        }
    }

    private func antibodyCooldown() -> TimeInterval {
        max(0.12, 0.34 - TimeInterval(rapidRank) * 0.055)
    }

    private func antibodyShotCount() -> Int {
        if rapidRank >= 4 {
            return 3
        }
        if rapidRank >= 2 {
            return 2
        }
        return 1
    }

    private func antibodySpreadStep() -> CGFloat {
        rapidRank >= 2 ? 0.18 : 0
    }

    private func antibodyDamage() -> CGFloat {
        1 + CGFloat(rapidRank) * 0.28
    }

    private func updateShots(delta: TimeInterval) {
        for shot in shots where !shot.dead {
            let previousPosition = shot.position
            if let targetId = shot.targetId, let target = enemies.first(where: { $0.id == targetId && !$0.dead }) {
                let toTarget = normalized(CGVector(dx: target.position.x - shot.position.x, dy: target.position.y - shot.position.y))
                let desired = CGVector(dx: toTarget.dx * Constants.shotSpeed, dy: toTarget.dy * Constants.shotSpeed)
                shot.velocity = lerp(shot.velocity, desired, min(Constants.shotHomingStrength * CGFloat(delta), 1))
            }

            shot.position.x += shot.velocity.dx * CGFloat(delta)
            shot.position.y += shot.velocity.dy * CGFloat(delta)
            shot.life -= delta

            if let enemy = firstEnemyHit(from: previousPosition, to: shot.position) {
                damage(enemy: enemy, amount: shot.damage)
                shot.dead = true
            }

            shot.node.position = baseToStage(shot.position)
            shot.node.zRotation = angle(for: shot.velocity)
            if shot.life <= 0 || shot.position.x > visibleBaseMaxX() + 140 || shot.position.y < -90 || shot.position.y > Constants.baseSize.height + 90 {
                shot.dead = true
            }
        }

        var liveShots: [Shot] = []
        liveShots.reserveCapacity(shots.count)
        for shot in shots {
            if shot.dead {
                recycleShot(shot)
            } else {
                liveShots.append(shot)
            }
        }
        shots = liveShots
    }

    private func damage(enemy: Enemy, amount: CGFloat, bypassAdenovirusShield: Bool = false, ignoreBossDamageScale: Bool = false) {
        guard !enemy.dead else {
            return
        }

        if enemy.kind == .boss, enemy.bossKind == .adenovirus, !enemy.shieldOpen, !bypassAdenovirusShield {
            enemy.node.run(.sequence([
                .colorize(with: UIColor(red: 0.6, green: 1.0, blue: 1.0, alpha: 1.0), colorBlendFactor: 0.65, duration: 0.04),
                .colorize(withColorBlendFactor: 0.28, duration: 0.10)
            ]))
            return
        }

        var bossDamageScale = enemy.damageScale
        if enemy.kind == .boss, !ignoreBossDamageScale {
            if enemy.bossKind == .rotavirus, !enemy.shieldOpen {
                bossDamageScale *= 0.34
                enemy.node.run(.sequence([
                    .colorize(with: UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 1.0), colorBlendFactor: 0.56, duration: 0.04),
                    .colorize(withColorBlendFactor: 0.26, duration: 0.10)
                ]))
            } else if enemy.bossKind == .lyssavirus, enemy.phase == 3 {
                bossDamageScale *= 1.38
            } else if enemy.bossKind == .norovirus, activeNorovirusDecoyCount() > 0 {
                bossDamageScale *= 0.58
            }
        }

        let appliedDamage = enemy.kind == .boss && !ignoreBossDamageScale ? amount * bossDamageScale : amount
        enemy.hp -= appliedDamage
        let canPlayHitFeedback = enemy.kind != .boss || bossHitFeedbackTimer <= 0
        let canShowHitFeedback = canPlayHitFeedback && reserveHitFlash(for: enemy)
        if canShowHitFeedback {
            spawnSpark(at: enemy.position, color: UIColor(red: 0.66, green: 1.0, blue: 0.9, alpha: 1.0), count: enemy.kind == .boss ? 5 : 6)
            enemy.node.removeAction(forKey: "hitFlash")
            enemy.node.run(.sequence([
                .colorize(with: UIColor(red: 1.0, green: 0.78, blue: 0.78, alpha: 1.0), colorBlendFactor: 0.8, duration: 0.03),
                .colorize(withColorBlendFactor: 0, duration: 0.08)
            ]), withKey: "hitFlash")
        }
        if enemy.kind == .boss {
            if canPlayHitFeedback {
                audio.playSFX(.bossHit)
                bossHitFeedbackTimer = 0.055
            }
        } else if enemy.kind == .influenza {
            audio.playSFX(.influenzaHit)
        } else {
            audio.playSFX(.hit)
        }

        if enemy.hp <= 0 {
            enemy.dead = true
            score += enemy.score
            if enemy.kind == .boss {
                bossDefeated = true
                bossesNeutralized += 1
                clearBossDecoys(for: enemy.bossKind)
                beginBossDeathAnimation(enemy)
                haptics.play(.heavyImpact)
                finishLevel(delay: 1.45)
                showBanner("\(activeMission.bossTarget ?? "Boss") neutralized")
                addScreenShake(duration: 0.34, magnitude: 18)
                audio.playSFX(.bossDefeated)
                return
            } else {
                levelKills += 1
                totalKills += 1
            }
            spawnSpark(at: enemy.position, color: UIColor(red: 0.5, green: 1.0, blue: 0.88, alpha: 1.0), count: 14)
            addScreenShake(duration: enemy.kind == .boss ? 0.28 : 0.08, magnitude: enemy.kind == .boss ? 16 : 3)
            audio.playSFX(enemy.kind == .boss ? .bossDefeated : .pop)
        }
    }

    private func updateProps(delta: TimeInterval) {
        for cell in redCells where !cell.dead {
            cell.position.x -= (cell.speed + 185 * cell.depth * 0.26) * CGFloat(delta)
            cell.position.y += sin(CGFloat(runTime) * 1.2 + cell.wobble) * cell.drift * CGFloat(delta)
            cell.rotation += cell.spin * CGFloat(delta)
            cell.node.position = baseToStage(cell.position)
            cell.node.zRotation = -cell.rotation
            if cell.position.x < offscreenLeftRemovalX(for: cell.node, grace: 24) {
                cell.dead = true
            }
        }

        redCells.removeAll { cell in
            if cell.dead {
                cell.node.removeFromParent()
                return true
            }
            return false
        }

        for platelet in platelets where !platelet.dead {
            platelet.position.x += platelet.velocity.dx * CGFloat(delta)
            platelet.position.y += platelet.velocity.dy * CGFloat(delta)
            platelet.position.x -= 185 * 0.3 * CGFloat(delta)
            platelet.angle += platelet.spin * CGFloat(delta)
            platelet.node.position = baseToStage(platelet.position)
            platelet.node.zRotation = -platelet.angle
            if platelet.position.x < offscreenLeftRemovalX(for: platelet.node, grace: 24) {
                platelet.dead = true
            }
        }

        platelets.removeAll { platelet in
            if platelet.dead {
                platelet.node.removeFromParent()
                return true
            }
            return false
        }
    }

    private func updateCollisions() {
        for enemy in enemies where !enemy.dead {
            if distance(enemy.position, player.position) <= enemy.radius + Constants.playerCollisionRadius {
                if player.dashTimer > 0 {
                    let push = normalized(CGVector(dx: enemy.position.x - player.position.x, dy: enemy.position.y - player.position.y))
                    enemy.velocity.dx += push.dx * 170
                    enemy.velocity.dy += push.dy * 170
                } else {
                    hurtPlayer(amount: enemy.damage, at: enemy.position)
                    if enemy.kind != .boss {
                        enemy.dead = true
                        spawnSpark(at: enemy.position, color: UIColor(red: 1.0, green: 0.25, blue: 0.35, alpha: 1.0), count: 12)
                    }
                }
            }
        }

        for cell in redCells where !cell.dead {
            let deltaToPlayer = CGVector(dx: player.position.x - cell.position.x, dy: player.position.y - cell.position.y)
            let hitDistance = vectorLength(deltaToPlayer)
            let collisionRadius = Constants.playerCollisionRadius + cell.radius * 0.72
            if hitDistance < collisionRadius, hitDistance > 0.001 {
                let normal = CGVector(dx: deltaToPlayer.dx / hitDistance, dy: deltaToPlayer.dy / hitDistance)
                let push = (collisionRadius - hitDistance) * 0.28
                player.position.x += normal.dx * push
                player.position.y += normal.dy * push
                player.velocity.dx += normal.dx * 42
                player.velocity.dy += normal.dy * 42
            }
        }

        for platelet in platelets where !platelet.dead {
            guard distance(platelet.position, player.position) <= Constants.playerCollisionRadius + platelet.radius * 0.86 else {
                continue
            }

            if player.dashTimer > 0 {
                platelet.dead = true
                spawnSpark(at: platelet.position, color: UIColor(red: 1.0, green: 0.82, blue: 0.32, alpha: 1.0), count: 12)
                if plateletHitSoundTimer <= 0 {
                    audio.playSFX(.plateletHit)
                    plateletHitSoundTimer = 0.18
                }
                continue
            }

            if plateletHitSoundTimer <= 0 {
                audio.playSFX(.plateletHit)
                plateletHitSoundTimer = 0.18
            }
            hurtPlayer(amount: 8, at: platelet.position, playDamageSound: false)
            platelet.dead = true
            spawnSpark(at: platelet.position, color: UIColor(red: 1.0, green: 0.82, blue: 0.32, alpha: 1.0), count: 10)
        }

        player.position.x = clamp(player.position.x, 60, Constants.baseSize.width - 90)
        player.position.y = clamp(player.position.y, 90, Constants.baseSize.height - 80)
        playerNode?.position = baseToStage(player.position)
    }

    private func updateLevelFlow(delta: TimeInterval) {
        if !activeMission.isEncounter, levelClearTimer <= 0, levelProgress() >= 1, levelKills >= levelGoal {
            finishLevel(delay: Constants.levelClearDelay)
        }

        guard levelClearTimer > 0 else {
            return
        }

        levelClearTimer = max(0, levelClearTimer - delta)
        if levelClearTimer == 0 {
            showLevelCompletePanel()
        }
    }

    private func finishLevel(delay: TimeInterval) {
        guard mode == .running, levelClearTimer <= 0 else {
            return
        }
        sectionsCleared += 1
        joystickVector = .zero
        fireTouchIds.removeAll()
        updateJoystickVisual()
        player.invulnerable = max(player.invulnerable, 3.0)
        pendingMusicCue = .upgrade
        pendingMusicTimer = 0.55
        stopBossEncounterSFX()
        audio.stopMusic()
        audio.stopAmbience()
        audio.playSFX(.levelComplete)
        haptics.play(.success)
        levelClearTimer = delay
    }

    private func showLevelCompletePanel() {
        mode = .levelComplete
        controlsNode.isHidden = true
        pauseOverlay.isHidden = true
        closePauseSubmenus()
        restartConfirmVisible = false
        restartConfirmOverlay.isHidden = true
        upgradeOverlay.isHidden = true
        gameOverOverlay.isHidden = true
        updateLevelCompleteOverlay()
        levelCompleteOverlay.isHidden = false
    }

    private func openUpgradeScreenOrContinue() {
        levelCompleteOverlay.isHidden = true
        if allUpgradesComplete() {
            startNextLevel()
        } else {
            showUpgradeSelection()
        }
    }

    private func showUpgradeSelection() {
        mode = .upgrade
        joystickVector = .zero
        fireTouchIds.removeAll()
        updateJoystickVisual()
        controlsNode.isHidden = true
        levelCompleteOverlay.isHidden = true
        updateUpgradeOverlay()
        upgradeOverlay.isHidden = false
        audio.stopAmbience()
        playDesiredMusic()
    }

    private func selectUpgrade(_ choice: UpgradeChoice) {
        guard rank(for: choice) < Constants.maxUpgradeRank else {
            audio.playSFX(.uiSelect)
            return
        }
        switch choice {
        case .rapid:
            rapidRank = min(Constants.maxUpgradeRank, rapidRank + 1)
        case .pulse:
            pulseRank = min(Constants.maxUpgradeRank, pulseRank + 1)
        case .dash:
            dashRank = min(Constants.maxUpgradeRank, dashRank + 1)
        }
        audio.playSFX(.upgradeSelected)
        haptics.play(.success)
        startNextLevel()
    }

    private func updateLevelCompleteOverlay() {
        let nextMission = mission(for: level + 1)
        let resultText: String
        if activeMission.isEncounter {
            let target = activeMission.bossTarget ?? activeMission.target
            resultText = "\(target) neutralized after \(levelKills) \(activeMission.target)"
        } else {
            resultText = "\(levelKills) \(activeMission.target) neutralized"
        }

        levelCompleteTitleLabel?.text = "Level \(level) Complete"
        levelCompleteBodyLabel?.text = """
        \(activeMission.name): \(activeMission.term)
        \(resultText)
        Score \(score)  |  Health \(Int(round(player.health)))%
        Next: \(nextMission.name) (\(nextMission.term))
        """
        levelCompleteActionLabel?.text = allUpgradesComplete() ? "Continue" : "Choose Adaptation"
    }

    private func updateUpgradeOverlay() {
        let nextMission = mission(for: level + 1)
        upgradeIntroLabel?.text = "Section \(level) cleared. Prepare for \(nextMission.name): \(nextMission.term)."

        for definition in Constants.upgrades {
            let rank = rank(for: definition.choice)
            let maxed = rank >= Constants.maxUpgradeRank
            upgradeRankLabels[definition.choice]?.text = upgradeCurrentText(for: definition, rank: rank)
            upgradeNextRankLabels[definition.choice]?.text = upgradeNextText(for: definition, rank: rank)
            upgradeButtonLabels[definition.choice]?.text = maxed ? "Maxed" : "Choose Rank \(rank + 1)"
            upgradeButtonLabels[definition.choice]?.alpha = maxed ? 0.58 : 1.0

            for (index, pip) in (upgradePips[definition.choice] ?? []).enumerated() {
                styleUpgradePip(pip, filled: index < rank)
            }
        }
    }

    private func upgradeCurrentText(for definition: UpgradeDefinition, rank: Int) -> String {
        guard rank > 0 else {
            return "Current: no adaptation yet"
        }

        let currentIndex = min(rank - 1, definition.ranks.count - 1)
        return "Current: Rank \(rank) - \(definition.ranks[currentIndex].current)"
    }

    private func upgradeNextText(for definition: UpgradeDefinition, rank: Int) -> String {
        guard rank < Constants.maxUpgradeRank else {
            return "Next: all 4 ranks unlocked"
        }

        let nextIndex = min(rank, definition.ranks.count - 1)
        return "Next: Rank \(rank + 1) - \(definition.ranks[nextIndex].next)"
    }

    private func updateUpgradePipPulse() {
        guard !upgradeOverlay.isHidden else {
            return
        }

        let pulse = 1.0 + sin(CGFloat(sceneTime) * 4.2) * 0.16
        for definition in Constants.upgrades {
            let rank = rank(for: definition.choice)
            for (index, pip) in (upgradePips[definition.choice] ?? []).enumerated() {
                styleUpgradePip(pip, filled: index < rank, pulse: pulse)
            }
        }
    }

    private func styleUpgradePip(_ pip: SKShapeNode, filled: Bool, pulse: CGFloat = 1.0) {
        if filled {
            let glow = clamp((pulse - 0.8) / 0.4, 0, 1)
            pip.fillColor = UIColor(
                red: 1.0,
                green: CGFloat.lerp(from: 0.72, to: 0.98, amount: glow),
                blue: CGFloat.lerp(from: 0.16, to: 0.62, amount: glow),
                alpha: 1.0
            )
            pip.strokeColor = UIColor(
                red: 1.0,
                green: CGFloat.lerp(from: 0.86, to: 1.0, amount: glow),
                blue: CGFloat.lerp(from: 0.28, to: 0.78, amount: glow),
                alpha: 1.0
            )
            pip.glowWidth = 8 + glow * 8
            pip.alpha = 1.0
            pip.setScale(1.0 + glow * 0.12)
        } else {
            pip.fillColor = UIColor(red: 0.08, green: 0.02, blue: 0.05, alpha: 0.72)
            pip.strokeColor = UIColor(red: 1.0, green: 0.76, blue: 0.24, alpha: 0.74)
            pip.glowWidth = 2.5
            pip.alpha = 0.90
            pip.setScale(1.0)
        }
    }

    private func updateGameOverOverlay() {
        gameOverSubtitleLabel?.text = "Run ended during \(activeMission.name): \(activeMission.term)."
        let best = profileStore.bestRun
        let adaptations = compactAdaptationSummary()
        if lastRunWasBest {
            gameOverRecordLabel?.text = "NEW BEST RUN\n\(score) pts | Lv \(level) | \(formatTime(runTime))\n\(adaptations)"
        } else if profileStore.hasBestRun {
            gameOverRecordLabel?.text = "BEST RUN\n\(best.score) pts | Lv \(best.level) | \(formatTime(best.survivalTime))\n\(adaptations)"
        } else {
            gameOverRecordLabel?.text = "RUN SUMMARY\nNo saved best yet\n\(adaptations)"
        }
        gameOverStatLabels["score"]?.text = "\(score)"
        gameOverStatLabels["level"]?.text = "\(level)"
        gameOverStatLabels["sections"]?.text = "\(sectionsCleared)"
        gameOverStatLabels["virions"]?.text = "\(totalKills)"
        gameOverStatLabels["bosses"]?.text = "\(bossesNeutralized)"
        gameOverStatLabels["time"]?.text = formatTime(runTime)
        gameOverAdaptationsLabel?.text = adaptations
    }

    private func compactAdaptationSummary() -> String {
        let summary = adaptationSummary()
        if summary == "No adaptations selected" {
            return "No adaptations"
        }
        return summary.replacingOccurrences(of: "  |  ", with: " | ")
    }

    private func rank(for choice: UpgradeChoice) -> Int {
        switch choice {
        case .rapid:
            return rapidRank
        case .pulse:
            return pulseRank
        case .dash:
            return dashRank
        }
    }

    private func allUpgradesComplete() -> Bool {
        Constants.upgrades.allSatisfy { rank(for: $0.choice) >= Constants.maxUpgradeRank }
    }

    private func adaptationSummary() -> String {
        let parts = Constants.upgrades.compactMap { definition -> String? in
            let rank = rank(for: definition.choice)
            guard rank > 0 else {
                return nil
            }
            let shortName: String
            switch definition.choice {
            case .rapid:
                shortName = "Rapid"
            case .pulse:
                shortName = "Pulse"
            case .dash:
                shortName = "Dash"
            }
            return "\(shortName) \(rank)"
        }
        return parts.isEmpty ? "No adaptations selected" : parts.joined(separator: "  |  ")
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = max(0, Int(seconds.rounded(.down)))
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    private func applySavedProfileSettings() {
        musicMuted = profileStore.musicMuted
        sfxMuted = profileStore.sfxMuted
        hapticsMuted = profileStore.hapticsMuted
        tiltSensitivity = profileStore.tiltSensitivity
        audio.setMusicMuted(musicMuted)
        audio.setSFXMuted(sfxMuted)
        haptics.setMuted(hapticsMuted)
        setTiltEnabled(profileStore.tiltEnabled, showBannerText: false)
        updatePauseToggleLabels()
        updateTitleBestRunLabel()
        updateTiltSensitivitySlider()
    }

    private func configureGameCenter() {
        gameCenter.onAuthenticationChanged = { [weak self] isAuthenticated in
            DispatchQueue.main.async {
                self?.leaderboardsLabel?.text = isAuthenticated ? "LEADERBOARDS" : "GAME CENTER"
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            self.gameCenter.authenticate(presentingViewController: self.presentingViewController()) { [weak self] in
                guard let self, self.profileStore.hasBestRun else {
                    return nil
                }
                return self.profileStore.bestRun
            }
        }
    }

    private func presentingViewController() -> UIViewController? {
        guard let view else {
            return nil
        }
        return view.window?.rootViewController ?? view.next as? UIViewController
    }

    private func playUITap() {
        audio.playSFX(.uiSelect)
        haptics.play(.selection)
    }

    private func playPauseResumeSFX() {
        audio.playSFX(.pauseResume, fadeOutAfter: 0.34, fadeDuration: 0.22)
    }

    private func openInputSettings() {
        closeAudioSettings()
        closeHowToPlay()
        inputSettingsVisible = true
        restartConfirmVisible = false
        restartConfirmOverlay.isHidden = true
        inputSettingsOverlay.isHidden = false
        resetTiltCalibrationFeedback()
        updatePauseToggleLabels()
        updateTiltSensitivitySlider()
    }

    private func closeInputSettings() {
        inputSettingsVisible = false
        tiltSensitivityTouchId = nil
        inputSettingsOverlay.isHidden = true
        resetTiltCalibrationFeedback()
    }

    private func openAudioSettings() {
        closeInputSettings()
        closeHowToPlay()
        audioSettingsVisible = true
        restartConfirmVisible = false
        restartConfirmOverlay.isHidden = true
        audioSettingsOverlay.isHidden = false
        updatePauseToggleLabels()
    }

    private func closeAudioSettings() {
        audioSettingsVisible = false
        audioSettingsOverlay.isHidden = true
    }

    private func openHowToPlay() {
        closeAudioSettings()
        closeInputSettings()
        howToPlayVisible = true
        restartConfirmVisible = false
        restartConfirmOverlay.isHidden = true
        howToPlayOverlay.isHidden = false
    }

    private func closeHowToPlay() {
        howToPlayVisible = false
        howToPlayOverlay.isHidden = true
    }

    private func closePauseSubmenus() {
        closeAudioSettings()
        closeInputSettings()
        closeHowToPlay()
    }

    private func startMotionInputIfNeeded() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.accelerometerUpdateInterval = 1.0 / 60.0
        if motionManager.isDeviceMotionAvailable, !motionManager.isDeviceMotionActive {
            motionManager.startDeviceMotionUpdates()
        } else if !motionManager.isDeviceMotionAvailable,
                  motionManager.isAccelerometerAvailable,
                  !motionManager.isAccelerometerActive {
            motionManager.startAccelerometerUpdates()
        }
    }

    @discardableResult
    private func calibrateTilt(showBannerText: Bool) -> Bool {
        startMotionInputIfNeeded()
        guard let sensor = rawTiltSensor(), vectorLength(sensor) > 0.001 else {
            tiltHasCalibration = false
            tiltVector = .zero
            updateJoystickVisual()
            if showBannerText {
                showBanner("Tilt sensor unavailable here")
            }
            return false
        }

        tiltNeutral = sensor
        tiltHasCalibration = true
        tiltVector = .zero
        updateJoystickVisual()
        return true
    }

    private func updateTiltVector(delta: TimeInterval) {
        guard tiltEnabled else {
            if vectorLength(tiltVector) > 0.001 {
                tiltVector = .zero
                updateJoystickVisual()
            }
            return
        }

        startMotionInputIfNeeded()
        guard let sensor = rawTiltSensor(), vectorLength(sensor) > 0.001 else {
            tiltVector = .zero
            if joystickTouchId == nil {
                updateJoystickVisual()
            }
            return
        }

        if !tiltHasCalibration {
            tiltNeutral = sensor
            tiltHasCalibration = true
        }

        let rawMove = CGVector(
            dx: sensor.dx - tiltNeutral.dx,
            dy: -(sensor.dy - tiltNeutral.dy)
        )
        var move = CGVector(
            dx: tiltAxisValue(from: rawMove.dx),
            dy: tiltAxisValue(from: rawMove.dy)
        )
        move = limit(move, maxLength: 1)
        tiltVector = lerp(tiltVector, move, min(Constants.tiltSmoothing * CGFloat(delta), 1))
        if vectorLength(tiltVector) < 0.015 {
            tiltVector = .zero
        }
        if joystickTouchId == nil {
            updateJoystickVisual()
        }
    }

    private func tiltAxisValue(from rawValue: CGFloat) -> CGFloat {
        let magnitude = abs(rawValue)
        guard magnitude > Constants.tiltDeadzone else {
            return 0
        }
        let adjusted = (magnitude - Constants.tiltDeadzone) * tiltSensitivity
        return rawValue < 0 ? -adjusted : adjusted
    }

    private func rawTiltSensor() -> CGVector? {
        let vector: CGVector?
        if let gravity = motionManager.deviceMotion?.gravity {
            vector = CGVector(dx: CGFloat(gravity.x), dy: CGFloat(gravity.y))
        } else if let acceleration = motionManager.accelerometerData?.acceleration {
            vector = CGVector(dx: CGFloat(acceleration.x), dy: CGFloat(acceleration.y))
        } else {
            vector = nil
        }

        guard let vector else {
            return nil
        }

        switch view?.window?.windowScene?.interfaceOrientation {
        case .landscapeLeft:
            return CGVector(dx: vector.dy, dy: -vector.dx)
        case .landscapeRight:
            return CGVector(dx: -vector.dy, dy: vector.dx)
        case .portraitUpsideDown:
            return CGVector(dx: -vector.dx, dy: -vector.dy)
        default:
            return vector
        }
    }

    private func updateTitleBestRunLabel() {
        guard let bestRunLabel else {
            return
        }

        guard profileStore.hasBestRun else {
            bestRunLabel.text = "Best Run\nNo immune run recorded yet"
            return
        }

        let best = profileStore.bestRun
        bestRunLabel.text = "Best Run: Score \(best.score) | Level \(best.level)\n\(best.sections) sections | \(best.neutralizations) neutralized | \(formatTime(best.survivalTime))"
    }

    private func updateAudio(delta: TimeInterval) {
        if let cue = pendingMusicCue {
            pendingMusicTimer = max(0, pendingMusicTimer - delta)
            if pendingMusicTimer == 0 {
                pendingMusicCue = nil
                audio.playMusic(cue)
            }
            return
        }

        if mode == .running || mode == .levelComplete || mode == .upgrade || mode == .title || mode == .gameOver {
            playDesiredMusic()
        }

        if shouldPlayVeinAmbience() {
            audio.playAmbience()
        } else {
            audio.stopAmbience()
        }
    }

    private func shouldPlayVeinAmbience() -> Bool {
        let bossWarningAudioActive = bossWarningStarted && !bossSpawned && bossWarningTimer > 0
        return mode == .running
            && levelClearTimer <= 0
            && pendingMusicCue == nil
            && !bossWarningAudioActive
    }

    private func playDesiredMusic() {
        guard pendingMusicCue == nil else {
            return
        }

        switch mode {
        case .title, .gameOver:
            audio.playMusic(.menu)
        case .levelComplete, .upgrade:
            audio.playMusic(.upgrade)
        case .running:
            if levelClearTimer > 0 {
                audio.playMusic(.upgrade)
                return
            }
            if bossWarningStarted && !bossSpawned && bossWarningTimer > 0 {
                return
            }
            if dangerMusicShouldPlay() {
                audio.playMusic(.danger)
            } else if activeMission.isEncounter && !bossDefeated && activeBoss() != nil {
                audio.playMusic(.boss)
            } else {
                audio.playMusic(.combat)
            }
        case .paused:
            break
        }
    }

    private func stopBossEncounterSFX() {
        audio.stopSFX(.bossWarning)
        audio.stopSFX(.bossPhase)
    }

    private func pauseBossWarningSFX() {
        audio.pauseSFX(.bossWarning)
    }

    private func resumeBossWarningSFXIfNeeded() {
        if bossWarningStarted && !bossSpawned && bossWarningTimer > 0 {
            audio.resumeSFX(.bossWarning)
        } else {
            audio.stopSFX(.bossWarning)
        }
    }

    private func dangerMusicShouldPlay() -> Bool {
        if player.health >= Constants.playerMaxHealth * Constants.dangerMusicResetRatio {
            dangerMusicActive = false
        }
        return dangerMusicActive
    }

    private func setMusicMuted(_ value: Bool) {
        musicMuted = value
        profileStore.musicMuted = value
        audio.setMusicMuted(value)
        updatePauseToggleLabels()
        if !value {
            playDesiredMusic()
            if shouldPlayVeinAmbience() {
                audio.playAmbience()
            }
        }
    }

    private func setSFXMuted(_ value: Bool) {
        sfxMuted = value
        profileStore.sfxMuted = value
        audio.setSFXMuted(value)
        updatePauseToggleLabels()
    }

    private func setHapticsMuted(_ value: Bool) {
        hapticsMuted = value
        profileStore.hapticsMuted = value
        haptics.setMuted(value)
        updatePauseToggleLabels()
    }

    private func setTiltSensitivity(_ value: CGFloat) {
        tiltSensitivity = clamp(value, Constants.tiltSensitivityMin, Constants.tiltSensitivityMax)
        profileStore.tiltSensitivity = tiltSensitivity
        updateTiltSensitivitySlider()
    }

    private func setTiltSensitivity(fromBaseX baseX: CGFloat) {
        let progress = clamp(
            (baseX - Constants.tiltSensitivitySliderLeftX) / Constants.tiltSensitivitySliderWidth,
            0,
            1
        )
        setTiltSensitivity(
            Constants.tiltSensitivityMin
                + progress * (Constants.tiltSensitivityMax - Constants.tiltSensitivityMin)
        )
    }

    private func updateTiltSensitivitySlider() {
        guard tiltSensitivityTrack.parent != nil else {
            return
        }
        let progress = clamp(
            (tiltSensitivity - Constants.tiltSensitivityMin) / (Constants.tiltSensitivityMax - Constants.tiltSensitivityMin),
            0,
            1
        )
        let fillWidth = max(6, Constants.tiltSensitivitySliderWidth * progress)
        let fillCenterX = Constants.tiltSensitivitySliderLeftX + fillWidth * 0.5
        tiltSensitivityFill.xScale = fillWidth / Constants.tiltSensitivitySliderWidth
        tiltSensitivityFill.position = baseToStage(CGPoint(x: fillCenterX, y: Constants.tiltSensitivitySliderY))
        let knobX = Constants.tiltSensitivitySliderLeftX + Constants.tiltSensitivitySliderWidth * progress
        tiltSensitivityKnob.position = baseToStage(CGPoint(x: knobX, y: Constants.tiltSensitivitySliderY))
        tiltSensitivityLabel?.text = tiltSensitivityDescription(for: tiltSensitivity)
    }

    private func tiltSensitivityDescription(for value: CGFloat) -> String {
        if value < 1.65 {
            return "Low"
        }
        if value > 2.75 {
            return "High"
        }
        return "Normal"
    }

    private func setTiltEnabled(_ value: Bool, showBannerText: Bool) {
        tiltEnabled = value
        profileStore.tiltEnabled = value
        joystickTouchId = nil
        joystickVector = .zero
        if value {
            startMotionInputIfNeeded()
            updateJoystickVisual()
            calibrateTilt(showBannerText: showBannerText)
        } else {
            tiltHasCalibration = false
            tiltVector = .zero
            updateJoystickVisual()
            if showBannerText {
                showBanner("Tilt movement disabled")
            }
        }
        updatePauseToggleLabels()
    }

    private func toggleTiltMode() {
        let enablingTilt = !tiltEnabled
        setTiltEnabled(enablingTilt, showBannerText: false)
        if enablingTilt {
            showTiltCalibrationFeedback(success: tiltHasCalibration)
        }
    }

    private func updatePauseToggleLabels() {
        audioSettingsLabel?.text = "Audio & Feedback"
        musicToggleLabel?.text = musicMuted ? "Music: Off" : "Music: On"
        sfxToggleLabel?.text = sfxMuted ? "Effects: Off" : "Effects: On"
        hapticsToggleLabel?.text = hapticsMuted ? "Haptics: Off" : "Haptics: On"
        inputSettingsLabel?.text = "Input Settings"
        howToPlayLabel?.text = "How to Play"
        tiltToggleLabel?.text = tiltEnabled ? "Tilt: On" : "Tilt: Off"
        tiltCalibrateLabel?.text = "Calibrate"
    }

    private func triggerDash(input: CGVector) {
        guard mode == .running, dashRank > 0, player.dashCooldown <= 0 else {
            return
        }
        var direction = input
        if vectorLength(direction) <= 0.001 {
            direction = lastFacing
        }
        direction = normalized(direction)
        updateHorizontalFacing(from: direction)
        let burstSpeed = 520 + CGFloat(dashRank) * 100
        player.velocity = limit(
            CGVector(
                dx: player.velocity.dx + direction.dx * burstSpeed,
                dy: player.velocity.dy + direction.dy * burstSpeed
            ),
            maxLength: 940
        )
        let dashDuration = Constants.dashDuration + TimeInterval(dashRank) * 0.035 + (dashRank >= 4 ? 0.06 : 0)
        player.dashTimer = dashDuration
        player.dashCooldown = max(0.45, 1.65 - TimeInterval(dashRank) * 0.22)
        let invulnerableSlip = dashDuration + (dashRank >= 4 ? 0.10 : 0.03)
        player.invulnerable = max(player.invulnerable, invulnerableSlip)
        dashTrailTimer = 0
        spawnPlayerWake(direction: direction, strength: 1.0)
        spawnSpark(at: player.position, color: UIColor(red: 0.62, green: 1.0, blue: 1.0, alpha: 1.0), count: 10)
        addScreenShake(duration: 0.11, magnitude: 5 + CGFloat(dashRank))
        audio.playSFX(.dash)
        haptics.play(.mediumImpact)
    }

    private func triggerPulse() {
        guard mode == .running, pulseRank > 0, player.pulseCooldown <= 0 else {
            return
        }

        let radius = Constants.pulseBaseRadius + CGFloat(pulseRank) * Constants.pulseRadiusPerRank
        let life = pulseLife(for: pulseRank)
        player.pulseCooldown = max(1.8, Constants.pulseCooldown - TimeInterval(pulseRank - 1) * 0.45)
        player.invulnerable = max(player.invulnerable, 0.6)

        let visuals = spawnPulseWave(at: player.position, radius: radius, rank: pulseRank, life: life)
        let pulse = ActivePulse(origin: player.position, maxRadius: radius, rank: pulseRank, life: life, visuals: visuals)
        activePulses.append(pulse)

        spawnSpark(at: player.position, color: UIColor(red: 0.42, green: 1.0, blue: 1.0, alpha: 1.0), count: 12)
        addScreenShake(duration: 0.20, magnitude: 8 + CGFloat(pulseRank) * 1.8)
        audio.playSFX(.pulse)
        haptics.play(.mediumImpact)
    }

    private func updateActivePulses(delta: TimeInterval) {
        activePulses.removeAll { pulse in
            pulse.age += delta
            let progress = clamp(CGFloat(pulse.age / max(0.001, pulse.life)), 0, 1)
            let expansionProgress = clamp(progress / Constants.pulseExpansionRatio, 0, 1)
            let eased = 1 - pow(1 - expansionProgress, 2)
            let currentRadius = pulse.maxRadius * CGFloat.lerp(from: 0.06, to: 1.0, amount: eased)
            updatePulseVisuals(pulse)
            _ = applyPulseHits(pulse, radius: currentRadius + Constants.pulseEdgeGrace)
            if progress >= 1 {
                pulse.visuals.forEach { $0.node.removeFromParent() }
                return true
            }
            return false
        }
    }

    private func updatePulseVisuals(_ pulse: ActivePulse) {
        for visual in pulse.visuals {
            let progress = clamp(CGFloat(pulse.age / max(0.001, visual.life)), 0, 1)
            let expansionProgress = clamp(progress / Constants.pulseExpansionRatio, 0, 1)
            let easedScale = 1 - pow(1 - expansionProgress, 2)
            let scale = CGFloat.lerp(from: visual.scaleStart, to: visual.scaleEnd, amount: easedScale)
            let fadeStart = clamp(visual.fadePower, 0.05, 0.95)
            let fadeProgress = progress <= fadeStart ? 0 : clamp((progress - fadeStart) / max(0.001, 1 - fadeStart), 0, 1)
            let fadeIn = clamp(progress / 0.10, 0, 1)

            visual.node.setScale(scale)
            visual.node.alpha = fadeIn * (1 - fadeProgress)
        }
    }

    @discardableResult
    private func applyPulseHits(_ pulse: ActivePulse, radius: CGFloat) -> Int {
        var hitCount = 0
        for enemy in enemies where !enemy.dead && !pulse.hitEnemyIds.contains(enemy.id) {
            guard distance(enemy.position, pulse.origin) <= radius + pulseEnemyRadius(enemy) else {
                continue
            }

            var push = normalized(CGVector(dx: enemy.position.x - pulse.origin.x, dy: enemy.position.y - pulse.origin.y))
            if vectorLength(push) <= 0.001 {
                push = rotated(CGVector(dx: 1, dy: 0), radians: CGFloat.random(in: 0...(CGFloat.pi * 2)))
            }
            enemy.velocity.dx += push.dx * (80 + CGFloat(pulse.rank) * 24)
            enemy.velocity.dy += push.dy * (80 + CGFloat(pulse.rank) * 24)
            pulse.hitEnemyIds.insert(enemy.id)
            let isBoss = enemy.kind == .boss
            if isBoss {
                damage(
                    enemy: enemy,
                    amount: pulseDamage(for: enemy, rank: pulse.rank),
                    bypassAdenovirusShield: true,
                    ignoreBossDamageScale: true
                )
            } else {
                neutralizeEnemyWithPulse(enemy)
            }
            hitCount += 1
        }

        for platelet in platelets where !platelet.dead {
            let plateletId = ObjectIdentifier(platelet)
            guard !pulse.hitPlateletIds.contains(plateletId),
                  distance(platelet.position, pulse.origin) <= radius + pulsePlateletRadius(platelet) else {
                continue
            }

            platelet.dead = true
            pulse.hitPlateletIds.insert(plateletId)
            spawnSpark(at: platelet.position, color: UIColor(red: 1.0, green: 0.82, blue: 0.32, alpha: 1.0), count: 10)
            hitCount += 1
        }
        return hitCount
    }

    private func pulseDamage(for enemy: Enemy, rank: Int) -> CGFloat {
        guard enemy.kind != .boss else {
            return 8 + CGFloat(rank) * 4
        }

        return enemy.hp
    }

    private func neutralizeEnemyWithPulse(_ enemy: Enemy) {
        guard !enemy.dead else {
            return
        }

        enemy.hp = 0
        enemy.dead = true
        score += enemy.score
        levelKills += 1
        totalKills += 1
        enemy.node.removeAllActions()
        enemy.node.removeFromParent()
        spawnSpark(at: enemy.position, color: UIColor(red: 0.5, green: 1.0, blue: 0.88, alpha: 1.0), count: 18)
        addScreenShake(duration: 0.08, magnitude: 3)
        audio.playSFX(enemy.kind == .influenza ? .influenzaHit : .pop)
    }

    private func pulseEnemyRadius(_ enemy: Enemy) -> CGFloat {
        pulseVisualRadius(node: enemy.node, fallback: enemy.radius, visualScale: 1.75)
    }

    private func pulsePlateletRadius(_ platelet: Platelet) -> CGFloat {
        max(platelet.radius * 1.25, pulseVisualRadius(node: platelet.node, fallback: platelet.radius, visualScale: 0.95))
    }

    private func pulseVisualRadius(node: SKSpriteNode, fallback: CGFloat, visualScale: CGFloat) -> CGFloat {
        let visualDiameter = max(node.size.width * abs(node.xScale), node.size.height * abs(node.yScale))
        guard visualDiameter > 0 else {
            return fallback
        }
        return max(fallback, visualDiameter * 0.5 * visualScale)
    }

    private func spawnPulseWave(at basePosition: CGPoint, radius: CGFloat, rank: Int, life: TimeInterval) -> [PulseVisual] {
        let rankBoost = pulseRankBoost(rank)
        let stagePosition = baseToStage(basePosition)

        let compressionRing = pulseWarpRing(
            radius: radius * 0.93,
            amplitude: 7.0 + rankBoost * 4.0,
            waves: 12,
            color: UIColor(red: 0.80, green: 1.0, blue: 1.0, alpha: 0.62),
            lineWidth: 6.5 + rankBoost * 2.0,
            zOffset: 4
        )
        let compressionVisual = addPulseVisual(compressionRing, position: stagePosition, scaleStart: 0.03, scaleEnd: 1.02, life: life * 0.98, fadePower: 0.52)

        let trailingRipple = pulseWarpRing(
            radius: radius * 0.66,
            amplitude: 4.0 + rankBoost * 3.0,
            waves: 9,
            color: UIColor(red: 1.0, green: 0.92, blue: 0.62, alpha: 0.36),
            lineWidth: 3.2 + rankBoost,
            zOffset: 2
        )
        let trailingVisual = addPulseVisual(trailingRipple, position: stagePosition, scaleStart: 0.05, scaleEnd: 1.24, life: life * 0.90, fadePower: 0.48)

        let upperGlint = pulseArc(
            radius: radius * 0.86,
            startAngle: 0.18 * .pi,
            endAngle: 0.47 * .pi,
            color: UIColor(red: 1.0, green: 1.0, blue: 0.92, alpha: 0.46),
            lineWidth: 4.0 + rankBoost,
            zOffset: 5
        )
        let upperGlintVisual = addPulseVisual(upperGlint, position: stagePosition, scaleStart: 0.04, scaleEnd: 1.08, life: life * 0.82, fadePower: 0.40)

        let lowerGlint = pulseArc(
            radius: radius * 0.78,
            startAngle: 1.22 * .pi,
            endAngle: 1.58 * .pi,
            color: UIColor(red: 0.66, green: 1.0, blue: 1.0, alpha: 0.34),
            lineWidth: 3.4 + rankBoost,
            zOffset: 5
        )
        let lowerGlintVisual = addPulseVisual(lowerGlint, position: stagePosition, scaleStart: 0.04, scaleEnd: 1.14, life: life * 0.84, fadePower: 0.42)

        let core = pulseCircle(
            radius: 46,
            fill: UIColor(red: 0.90, green: 1.0, blue: 1.0, alpha: 0.22),
            stroke: UIColor(red: 1.0, green: 0.88, blue: 0.40, alpha: 0.42),
            lineWidth: 2.0,
            zOffset: 7
        )
        let coreVisual = addPulseVisual(core, position: stagePosition, scaleStart: 0.16, scaleEnd: 1.7, life: min(0.38, life * 0.30), fadePower: 0.16)

        let sphere = pulseCircle(
            radius: radius,
            fill: UIColor(red: 0.24, green: 0.96, blue: 1.0, alpha: 0.075),
            stroke: UIColor(red: 0.24, green: 0.96, blue: 1.0, alpha: 0.10),
            lineWidth: 1.2,
            zOffset: 0
        )
        let sphereVisual = addPulseVisual(sphere, position: stagePosition, scaleStart: 0.01, scaleEnd: 1.0, life: life, fadePower: 0.54)

        let innerGlow = pulseCircle(
            radius: radius * 0.46,
            fill: UIColor(red: 0.78, green: 1.0, blue: 0.92, alpha: 0.10),
            stroke: UIColor(red: 0.90, green: 1.0, blue: 0.98, alpha: 0.14),
            lineWidth: 1.2,
            zOffset: 1
        )
        let innerVisual = addPulseVisual(innerGlow, position: stagePosition, scaleStart: 0.02, scaleEnd: 1.24, life: life * 0.90, fadePower: 0.46)

        let brightRim = pulseRing(
            radius: radius,
            color: UIColor(red: 0.78, green: 1.0, blue: 1.0, alpha: 1.0),
            lineWidth: 9.0 + rankBoost * 3.5,
            zOffset: 6
        )
        let brightVisual = addPulseVisual(brightRim, position: stagePosition, scaleStart: 0.01, scaleEnd: 1.0, life: life, fadePower: 0.56)

        let goldRim = pulseRing(
            radius: radius * 0.80,
            color: UIColor(red: 1.0, green: 0.82, blue: 0.34, alpha: 0.86),
            lineWidth: 3.6 + rankBoost * 1.5,
            zOffset: 5
        )
        let goldVisual = addPulseVisual(goldRim, position: stagePosition, scaleStart: 0.02, scaleEnd: 1.16, life: life * 0.92, fadePower: 0.52)

        return [
            compressionVisual,
            trailingVisual,
            upperGlintVisual,
            lowerGlintVisual,
            coreVisual,
            sphereVisual,
            innerVisual,
            brightVisual,
            goldVisual
        ]
    }

    private func pulseWarpRing(radius: CGFloat, amplitude: CGFloat, waves: Int, color: UIColor, lineWidth: CGFloat, zOffset: CGFloat) -> SKShapeNode {
        let ring = SKShapeNode(path: radialRipplePath(radius: radius, amplitude: amplitude, waves: waves))
        ring.fillColor = .clear
        ring.strokeColor = color
        ring.lineWidth = lineWidth
        ring.lineJoin = .round
        ring.lineCap = .round
        ring.glowWidth = max(2, lineWidth * 0.65)
        ring.zPosition = ZLayer.particles + zOffset
        return ring
    }

    private func radialRipplePath(radius: CGFloat, amplitude: CGFloat, waves: Int) -> CGPath {
        let path = CGMutablePath()
        let steps = 128
        for index in 0...steps {
            let t = CGFloat(index) / CGFloat(steps)
            let angle = t * CGFloat.pi * 2
            let ripple = sin(angle * CGFloat(waves)) * amplitude + sin(angle * CGFloat(max(3, waves / 2))) * amplitude * 0.32
            let localRadius = radius + ripple
            let point = CGPoint(x: cos(angle) * localRadius, y: sin(angle) * localRadius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    private func pulseArc(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, color: UIColor, lineWidth: CGFloat, zOffset: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        let arc = SKShapeNode(path: path)
        arc.fillColor = .clear
        arc.strokeColor = color
        arc.lineWidth = lineWidth
        arc.lineCap = .round
        arc.glowWidth = max(2, lineWidth * 0.7)
        arc.zPosition = ZLayer.particles + zOffset
        return arc
    }

    private func pulseCircle(radius: CGFloat, fill: UIColor, stroke: UIColor, lineWidth: CGFloat, zOffset: CGFloat) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = fill
        circle.strokeColor = stroke
        circle.lineWidth = lineWidth
        circle.zPosition = ZLayer.particles + zOffset
        return circle
    }

    private func pulseRing(radius: CGFloat, color: UIColor, lineWidth: CGFloat, zOffset: CGFloat) -> SKShapeNode {
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.fillColor = .clear
        ring.strokeColor = color
        ring.lineWidth = lineWidth
        ring.lineJoin = .round
        ring.lineCap = .round
        ring.zPosition = ZLayer.particles + zOffset
        return ring
    }

    private func addPulseVisual(
        _ node: SKNode,
        position: CGPoint,
        scaleStart: CGFloat,
        scaleEnd: CGFloat,
        life: TimeInterval,
        fadePower: CGFloat
    ) -> PulseVisual {
        node.position = position
        node.alpha = 0
        node.setScale(scaleStart)
        particleNode.addChild(node)
        return PulseVisual(node: node, scaleStart: scaleStart, scaleEnd: scaleEnd, life: life, fadePower: fadePower)
    }

    private func pulseRankBoost(_ rank: Int) -> CGFloat {
        let denominator = max(1, Constants.maxUpgradeRank - 1)
        return clamp(CGFloat(rank - 1) / CGFloat(denominator), 0, 1)
    }

    private func pulseLife(for rank: Int) -> TimeInterval {
        Constants.pulseBaseLife + TimeInterval(pulseRankBoost(rank)) * Constants.pulseRankLifeBonus
    }

    private func updatePlayerWake(delta: TimeInterval) {
        let speed = vectorLength(player.velocity)
        if player.dashTimer > 0 {
            dashTrailTimer -= delta
            if dashTrailTimer <= 0 {
                spawnPlayerWake(direction: speed > 1 ? player.velocity : lastFacing, strength: 1.0)
                dashTrailTimer = 0.045
            }
            return
        }

        guard speed > 110 else {
            swimWakeTimer = 0.08
            return
        }

        swimWakeTimer -= delta
        if swimWakeTimer <= 0 {
            spawnPlayerWake(direction: player.velocity, strength: 0.34)
            swimWakeTimer = 0.18
        }
    }

    private func spawnPlayerWake(direction: CGVector, strength: CGFloat) {
        let forward = normalized(direction)
        guard vectorLength(forward) > 0.001 else {
            return
        }

        let side = CGVector(dx: -forward.dy, dy: forward.dx)
        let count = strength > 0.7 ? 2 : 1
        for _ in 0..<count {
            guard reserveCosmeticNode() else {
                continue
            }
            let sideJitter = CGFloat.random(in: -18...18) * max(strength, 0.45)
            let wakeOrigin = CGPoint(
                x: player.position.x - forward.dx * 42 + side.dx * sideJitter,
                y: player.position.y - forward.dy * 42 + side.dy * sideJitter
            )
            let wake = SKShapeNode(ellipseOf: CGSize(width: 70 * max(strength, 0.45), height: 20 * max(strength, 0.45)))
            wake.fillColor = UIColor(red: 0.45, green: 1.0, blue: 1.0, alpha: 0.20 * strength)
            wake.strokeColor = UIColor(red: 0.90, green: 1.0, blue: 1.0, alpha: 0.25 * strength)
            wake.lineWidth = 1.2
            wake.position = baseToStage(wakeOrigin)
            wake.zRotation = angle(for: forward)
            wake.zPosition = ZLayer.particles - 1
            particleNode.addChild(wake)

            let destination = CGPoint(
                x: wakeOrigin.x - forward.dx * CGFloat.random(in: 28...58),
                y: wakeOrigin.y - forward.dy * CGFloat.random(in: 28...58)
            )
            wake.run(.sequence([
                .group([
                    .move(to: baseToStage(destination), duration: 0.34),
                    .fadeOut(withDuration: 0.34),
                    .scale(to: 1.45, duration: 0.34)
                ]),
                .removeFromParent()
            ]))
        }
    }

    private func addScreenShake(duration: TimeInterval, magnitude: CGFloat) {
        screenShakeDuration = max(screenShakeDuration, duration)
        screenShakeTimer = max(screenShakeTimer, duration)
        screenShakeMagnitude = max(screenShakeMagnitude, magnitude)
    }

    private func updateScreenShake(delta: TimeInterval) {
        guard mode == .running, screenShakeTimer > 0 else {
            clearScreenShake()
            return
        }

        screenShakeTimer = max(0, screenShakeTimer - delta)
        let progress = CGFloat(screenShakeTimer / max(0.001, screenShakeDuration))
        let magnitude = screenShakeMagnitude * progress * progress
        stageNode.position = CGPoint(
            x: stageOrigin.x + CGFloat.random(in: -magnitude...magnitude),
            y: stageOrigin.y + CGFloat.random(in: -magnitude...magnitude)
        )

        if screenShakeTimer <= 0 {
            clearScreenShake()
        }
    }

    private func clearScreenShake() {
        screenShakeTimer = 0
        screenShakeDuration = 0
        screenShakeMagnitude = 0
        stageNode.position = stageOrigin
    }

    private func hurtPlayer(amount: CGFloat, at position: CGPoint, playDamageSound: Bool = true) {
        guard player.invulnerable <= 0 else {
            return
        }
        player.health = max(0, player.health - amount)
        player.hurtTimer = 0.7
        player.invulnerable = 0.55
        if player.health <= Constants.playerMaxHealth * Constants.dangerMusicThreshold {
            dangerMusicActive = true
        }
        if playDamageSound {
            audio.playSFX(.playerDamage)
        }
        haptics.play(.warning)
        addScreenShake(duration: 0.18, magnitude: 10)
        if player.health <= 0 {
            endRun()
        }
    }

    private func updateHUD() {
        scoreLabel?.text = "\(score)"
        missionLabel?.text = activeMission.name
        levelLabel?.text = "\(level)"
        if activeMission.isEncounter, let boss = activeBoss() {
            targetLabel?.text = "\(Int(ceil(boss.hp))) integrity left"
        } else if activeMission.isEncounter, bossWarningStarted && !bossSpawned {
            targetLabel?.text = "Pathogen signal building"
        } else {
            let remaining = max(0, levelGoal - levelKills)
            if remaining == 0 && levelProgress() >= 1 {
                targetLabel?.text = "Vessel section clear"
            } else if remaining == 0 {
                targetLabel?.text = "Hold vessel lane"
            } else {
                targetLabel?.text = "\(remaining) \(activeMission.target) left"
            }
        }
        let healthRatio = clamp(player.health / Constants.playerMaxHealth, 0, 1)
        healthFill?.xScale = healthRatio
        progressFill?.xScale = combinedLevelProgress()
    }

    private func combinedLevelProgress() -> CGFloat {
        if activeMission.isEncounter {
            if bossDefeated {
                return 1
            }
            let approachProgress = clamp(levelProgress() / max(0.05, bossTriggerProgress), 0, 1) * 0.82
            if let boss = activeBoss() {
                let bossProgress = 1 - clamp(boss.hp / max(1, boss.maxHP), 0, 1)
                return 0.82 + bossProgress * 0.18
            }
            return approachProgress
        }
        let killProgress = clamp(CGFloat(levelKills) / max(1, CGFloat(levelGoal)), 0, 1)
        return (levelProgress() + killProgress) * 0.5
    }

    private func updateAbilityControls() {
        let dashReady = dashRank > 0 && player.dashCooldown <= 0
        dashButton.fillColor = UIColor(red: 0.70, green: 1.0, blue: 1.0, alpha: dashRank > 0 ? 0.22 : 0.10)
        dashButton.strokeColor = dashReady
            ? UIColor(red: 1.0, green: 0.90, blue: 0.46, alpha: 0.90)
            : UIColor(red: 0.86, green: 1.0, blue: 1.0, alpha: dashRank > 0 ? 0.58 : 0.34)
        dashButton.glowWidth = dashReady ? 4 : 2
        if dashRank <= 0 {
            dashLabel?.text = "LOCKED"
            dashLabel?.fontColor = UIColor(red: 0.70, green: 0.86, blue: 0.88, alpha: 0.72)
        } else if dashReady {
            dashLabel?.text = "DASH"
            dashLabel?.fontColor = UIColor(red: 1.0, green: 0.92, blue: 0.50, alpha: 1.0)
        } else {
            dashLabel?.text = String(format: "%.1fs", player.dashCooldown)
            dashLabel?.fontColor = UIColor(red: 0.72, green: 1.0, blue: 1.0, alpha: 0.90)
        }

        let pulseReady = pulseRank > 0 && player.pulseCooldown <= 0
        pulseButton.fillColor = UIColor(red: 0.70, green: 1.0, blue: 1.0, alpha: pulseRank > 0 ? 0.22 : 0.10)
        pulseButton.strokeColor = pulseReady
            ? UIColor(red: 1.0, green: 0.90, blue: 0.46, alpha: 0.90)
            : UIColor(red: 0.86, green: 1.0, blue: 1.0, alpha: pulseRank > 0 ? 0.58 : 0.34)
        pulseButton.glowWidth = pulseReady ? 4 : 2
        if pulseRank <= 0 {
            pulseLabel?.text = "LOCKED"
            pulseLabel?.fontColor = UIColor(red: 0.70, green: 0.86, blue: 0.88, alpha: 0.72)
        } else if pulseReady {
            pulseLabel?.text = "PULSE"
            pulseLabel?.fontColor = UIColor(red: 1.0, green: 0.92, blue: 0.50, alpha: 1.0)
        } else {
            pulseLabel?.text = String(format: "%.1fs", player.pulseCooldown)
            pulseLabel?.fontColor = UIColor(red: 0.72, green: 1.0, blue: 1.0, alpha: 0.90)
        }
    }

    private func findLockTarget() -> Enemy? {
        var bestEnemy: Enemy?
        var bestScore = -CGFloat.infinity
        for enemy in enemies where !enemy.dead && enemy.hp > 0 && enemy.position.x > -enemy.radius - 24 && enemy.position.x < visibleBaseMaxX() + enemy.radius + 120 {
            let score = enemyLockScore(enemy)
            if score > bestScore {
                bestScore = score
                bestEnemy = enemy
            }
        }
        return bestEnemy
    }

    private func enemyLockScore(_ enemy: Enemy) -> CGFloat {
        let delta = CGVector(dx: enemy.position.x - player.position.x, dy: enemy.position.y - player.position.y)
        let distance = vectorLength(delta)
        let nearlyTouching = distance < 170
        let inFront = delta.dx > -48
        let inLane = abs(delta.dy) < Constants.lockVerticalRange
        if !nearlyTouching && (!inFront || (distance > Constants.lockTargetRange && !inLane)) {
            return -1_000_000
        }
        let closeness = 1 - clamp(distance / Constants.lockTargetRange, 0, 1)
        let laneMatch = 1 - clamp(abs(delta.dy) / Constants.lockVerticalRange, 0, 1)
        let aheadBonus: CGFloat = delta.dx > 0 ? 1 : 0.28
        let typeBonus: CGFloat
        switch enemy.kind {
        case .boss:
            typeBonus = 2.8
        case .bossDecoy:
            typeBonus = 0.85
        case .influenza:
            typeBonus = 1.2
        case .fast:
            typeBonus = 0.45
        case .tank:
            typeBonus = 0.35
        default:
            typeBonus = 0
        }
        let stickiness: CGFloat = enemy.id == lockTargetId ? 1.8 : 0
        let behindPenalty = delta.dx < 0 ? abs(delta.dx) * 0.018 : 0
        return closeness * 5 + laneMatch * 3.2 + aheadBonus + typeBonus + stickiness - behindPenalty
    }

    private func firstEnemyHit(from: CGPoint, to: CGPoint) -> Enemy? {
        var closestEnemy: Enemy?
        var closestDistance = CGFloat.infinity
        for enemy in enemies where !enemy.dead {
            guard segmentHitsCircle(from: from, to: to, center: enemy.position, radius: enemy.radius + Constants.shotHitRadius) else {
                continue
            }
            let hitDistance = distanceSquared(from, enemy.position)
            if hitDistance < closestDistance {
                closestDistance = hitDistance
                closestEnemy = enemy
            }
        }
        return closestEnemy
    }

    private func segmentHitsCircle(from: CGPoint, to: CGPoint, center: CGPoint, radius: CGFloat) -> Bool {
        let segment = CGVector(dx: to.x - from.x, dy: to.y - from.y)
        let lengthSquared = segment.dx * segment.dx + segment.dy * segment.dy
        var closest = from
        if lengthSquared > 0.001 {
            let centerDelta = CGVector(dx: center.x - from.x, dy: center.y - from.y)
            let t = clamp((centerDelta.dx * segment.dx + centerDelta.dy * segment.dy) / lengthSquared, 0, 1)
            closest = CGPoint(x: from.x + segment.dx * t, y: from.y + segment.dy * t)
        }
        return distance(closest, center) <= radius
    }

    private func spawnSpark(at basePosition: CGPoint, color: UIColor, count: Int) {
        let sparkCount = reserveCosmeticNodes(requested: count, keepOneWhenTight: true)
        guard sparkCount > 0 else {
            return
        }

        for _ in 0..<sparkCount {
            let radius = CGFloat.random(in: 2...5)
            let dot = dequeueSparkNode(radius: radius, color: color, position: baseToStage(basePosition))

            let angle = CGFloat.random(in: 0...(CGFloat.pi * 2))
            let distance = CGFloat.random(in: 18...54)
            let destination = CGPoint(
                x: dot.position.x + cos(angle) * distance,
                y: dot.position.y - sin(angle) * distance
            )
            dot.run(.sequence([
                .group([
                    .move(to: destination, duration: 0.35),
                    .fadeOut(withDuration: 0.35),
                    .scale(to: 0.2, duration: 0.35)
                ]),
                .run { [weak self, weak dot] in
                    self?.recycleSparkNode(dot)
                }
            ]))
        }
    }

    private func keyboardMoveVector() -> CGVector {
        var move = CGVector.zero
        if pressedKeys.contains(.keyboardW) || pressedKeys.contains(.keyboardUpArrow) {
            move.dy -= 1
        }
        if pressedKeys.contains(.keyboardS) || pressedKeys.contains(.keyboardDownArrow) {
            move.dy += 1
        }
        if pressedKeys.contains(.keyboardA) || pressedKeys.contains(.keyboardLeftArrow) {
            move.dx -= 1
        }
        if pressedKeys.contains(.keyboardD) || pressedKeys.contains(.keyboardRightArrow) {
            move.dx += 1
        }
        return move
    }

    private func currentMovementVector() -> CGVector {
        let keyboard = keyboardMoveVector()
        if vectorLength(keyboard) > 0.001 {
            return keyboard
        }
        if tiltEnabled, vectorLength(tiltVector) > 0.001 {
            return tiltVector
        }
        if vectorLength(joystickVector) > 0.001 {
            return joystickVector
        }
        return joystickVector
    }

    private func updateHorizontalFacing(from direction: CGVector) {
        if direction.dx > 0.05 {
            lastFacing = CGVector(dx: 1, dy: 0)
        } else if direction.dx < -0.05 {
            lastFacing = CGVector(dx: -1, dy: 0)
        }
    }

    private func updateLateralSwimSFX(for move: CGVector) {
        let normalizedMove = vectorLength(move) > 0.001 ? normalized(move) : .zero
        let inputSign: Int
        if normalizedMove.dx > 0.35 {
            inputSign = 1
        } else if normalizedMove.dx < -0.35 {
            inputSign = -1
        } else {
            inputSign = 0
        }

        if inputSign != 0 && horizontalSwimSoundInput != inputSign {
            audio.playSFX(.swimSurge)
        }
        horizontalSwimSoundInput = inputSign
    }

    private func updateJoystick(with basePoint: CGPoint) {
        let offset = CGVector(dx: basePoint.x - Constants.joystickCenter.x, dy: basePoint.y - Constants.joystickCenter.y)
        var normalizedOffset = CGVector(dx: offset.dx / Constants.joystickRadius, dy: offset.dy / Constants.joystickRadius)
        if vectorLength(normalizedOffset) < Constants.joystickDeadzone {
            normalizedOffset = .zero
        } else {
            normalizedOffset = limit(normalizedOffset, maxLength: 1)
        }
        joystickVector = normalizedOffset
        updateJoystickVisual()
    }

    private func updateJoystickVisual() {
        joystickRing.isHidden = tiltEnabled
        joystickKnob.isHidden = tiltEnabled
        guard !tiltEnabled else {
            return
        }

        let displayVector = joystickVector
        let travel = Constants.joystickRadius - Constants.joystickKnobRadius - 8
        let baseKnob = CGPoint(
            x: Constants.joystickCenter.x + displayVector.dx * travel,
            y: Constants.joystickCenter.y + displayVector.dy * travel
        )
        joystickKnob.position = baseToStage(baseKnob)
        joystickKnob.alpha = vectorLength(displayVector) > 0.01 ? 0.92 : 0.62
        joystickRing.strokeColor = UIColor(red: 0.90, green: 1.0, blue: 1.0, alpha: 0.70)
    }

    private func endTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            let touchId = ObjectIdentifier(touch)
            if touchId == joystickTouchId {
                joystickTouchId = nil
                joystickVector = .zero
                updateJoystickVisual()
            }
            if touchId == tiltSensitivityTouchId {
                tiltSensitivityTouchId = nil
                haptics.prepare()
            }
            fireTouchIds.remove(touchId)
        }
    }

    private func texture(named name: String, extension fileExtension: String, subdirectory: String) -> SKTexture? {
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension, subdirectory: subdirectory),
              let image = UIImage(contentsOfFile: url.path) else {
            assertionFailure("Missing texture: \(subdirectory)/\(name).\(fileExtension)")
            return nil
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }

    private static func makeSparkTexture() -> SKTexture {
        let size = CGSize(width: 12, height: 12)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let colors = [
                UIColor.white.withAlphaComponent(0.95).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor
            ] as CFArray
            let locations: [CGFloat] = [0.0, 1.0]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else {
                UIColor.white.setFill()
                cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
                return
            }
            cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                startRadius: 0,
                endCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                endRadius: size.width * 0.5,
                options: [.drawsAfterEndLocation]
            )
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }

    private func regionTexture(from texture: SKTexture, frame: SpriteFrame) -> SKTexture {
        let width = texture.size().width
        let height = texture.size().height
        let rect = CGRect(
            x: frame.rect.minX / width,
            y: (height - frame.rect.maxY) / height,
            width: frame.rect.width / width,
            height: frame.rect.height / height
        )
        let region = SKTexture(rect: rect, in: texture)
        region.filteringMode = .linear
        return region
    }

    private func playerSpriteSize(for frame: SpriteFrame, matchIdleHeight: Bool = false) -> CGSize {
        if matchIdleHeight {
            let targetHeight = AtlasFrames.whiteCell[0].rect.height * Constants.playerVisualScale
            let scale = targetHeight / frame.rect.height
            return CGSize(width: frame.rect.width * scale, height: targetHeight)
        }

        return CGSize(
            width: frame.rect.width * Constants.playerVisualScale,
            height: frame.rect.height * Constants.playerVisualScale
        )
    }

    private func overlayShade(alpha: CGFloat) -> SKShapeNode {
        let shade = SKShapeNode()
        shade.name = "FullScreenOverlayShade"
        shade.fillColor = UIColor(red: 0.02, green: 0.0, blue: 0.02, alpha: alpha)
        shade.strokeColor = .clear
        shade.zPosition = ZLayer.overlay
        updateOverlayShadeFrame(shade)
        return shade
    }

    private func updateOverlayShadeFrames() {
        overlayNode.enumerateChildNodes(withName: "//FullScreenOverlayShade") { node, _ in
            if let shade = node as? SKShapeNode {
                self.updateOverlayShadeFrame(shade)
            }
        }
    }

    private func updateOverlayShadeFrame(_ shade: SKShapeNode) {
        let scale = max(stageScale, 0.001)
        let margin: CGFloat = 120
        let shadeSize = CGSize(
            width: max(Constants.baseSize.width, size.width / scale) + margin,
            height: max(Constants.baseSize.height, size.height / scale) + margin
        )
        let rect = CGRect(
            x: -shadeSize.width * 0.5,
            y: -shadeSize.height * 0.5,
            width: shadeSize.width,
            height: shadeSize.height
        )
        shade.path = CGPath(rect: rect, transform: nil)
        shade.position = CGPoint(
            x: (size.width * 0.5 - stageOrigin.x) / scale,
            y: (size.height * 0.5 - stageOrigin.y) / scale
        )
    }

    private func addArtButton(
        to parent: SKNode,
        center: CGPoint,
        size: CGSize,
        title: String,
        fontSize: CGFloat,
        drawFrame: Bool = true
    ) -> (shape: SKShapeNode, label: SKLabelNode) {
        if drawFrame, let pauseCompleteTexture {
            let frame = SKSpriteNode(texture: regionTexture(from: pauseCompleteTexture, frame: AtlasFrames.buttonFrame))
            frame.position = baseToStage(center)
            frame.size = CGSize(width: size.width + 30, height: size.height + 10)
            frame.zPosition = ZLayer.overlay + 23
            parent.addChild(frame)
        }

        let hitShape = SKShapeNode(rectOf: size, cornerRadius: 8)
        hitShape.fillColor = UIColor(red: 0.10, green: 0.74, blue: 0.82, alpha: pauseCompleteTexture == nil ? 0.88 : 0.001)
        hitShape.strokeColor = pauseCompleteTexture == nil ? UIColor(red: 1.0, green: 0.88, blue: 0.42, alpha: 0.92) : .clear
        hitShape.lineWidth = pauseCompleteTexture == nil ? 2 : 0
        hitShape.position = baseToStage(center)
        hitShape.zPosition = ZLayer.overlay + 26
        parent.addChild(hitShape)

        let text = label(title, size: fontSize, color: UIColor(red: 1.0, green: 0.96, blue: 0.82, alpha: 1.0))
        text.position = baseToStage(CGPoint(x: center.x, y: center.y + 1))
        text.zPosition = ZLayer.overlay + 27
        parent.addChild(text)
        return (hitShape, text)
    }

    private func label(_ text: String, size: CGFloat, color: UIColor) -> SKLabelNode {
        let node = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        node.text = text
        node.fontSize = size
        node.fontColor = color
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        node.zPosition = ZLayer.overlay + 4
        return node
    }

    private func multilineLabel(_ text: String, size: CGFloat, color: UIColor, width: CGFloat, lines: Int) -> SKLabelNode {
        let node = label(text, size: size, color: color)
        node.numberOfLines = lines
        node.preferredMaxLayoutWidth = width
        node.lineBreakMode = .byWordWrapping
        return node
    }

    private func baseToStage(_ basePoint: CGPoint) -> CGPoint {
        CGPoint(x: basePoint.x, y: Constants.baseSize.height - basePoint.y)
    }

    private func visibleBaseMinX() -> CGFloat {
        guard stageScale > 0 else {
            return 0
        }
        return -stageOrigin.x / stageScale
    }

    private func visibleBaseMaxX() -> CGFloat {
        guard stageScale > 0 else {
            return Constants.baseSize.width
        }
        return (size.width - stageOrigin.x) / stageScale
    }

    private func offscreenLeftRemovalX(for node: SKSpriteNode, grace: CGFloat) -> CGFloat {
        visibleBaseMinX() - node.size.width * 0.5 - grace
    }

    private func offscreenRightSpawnX(forVisualWidth visualWidth: CGFloat, grace: CGFloat) -> CGFloat {
        max(Constants.baseSize.width, visibleBaseMaxX()) + visualWidth * 0.5 + grace
    }

    private func scenePointToBase(_ scenePoint: CGPoint) -> CGPoint {
        let localX = (scenePoint.x - stageOrigin.x) / stageScale
        let localY = (scenePoint.y - stageOrigin.y) / stageScale
        return CGPoint(x: localX, y: Constants.baseSize.height - localY)
    }
}

private enum AudioCue: CaseIterable {
    case menu
    case combat
    case danger
    case boss
    case upgrade
    case ambience
    case shot
    case hit
    case pop
    case swimSurge
    case dash
    case pulse
    case levelComplete
    case bossWarning
    case bossHit
    case bossDefeated
    case bossPhase
    case buddingSplit
    case influenzaHit
    case influenzaReplicate
    case playerDamage
    case playerDeath
    case plateletHit
    case pauseOpen
    case pauseResume
    case restartConfirm
    case upgradeHover
    case upgradeSelected
    case uiSelect

    var file: (name: String, extension: String) {
        switch self {
        case .menu:
            return ("Menu music", "mp3")
        case .combat:
            return ("Normal vessel combat loop", "mp3")
        case .danger:
            return ("High-danger combat loop", "mp3")
        case .boss:
            return ("Boss loop", "mp3")
        case .upgrade:
            return ("Upgrade tree loop", "mp3")
        case .ambience:
            return ("Bloodstream ambience", "wav")
        case .shot:
            return ("Antibody shot", "wav")
        case .hit:
            return ("Antibody hit", "wav")
        case .pop:
            return ("Virus pop", "wav")
        case .swimSurge:
            return ("Chemotaxis dash", "wav")
        case .dash:
            return ("Chemotaxis dash upgraded", "wav")
        case .pulse:
            return ("Complement pulse", "wav")
        case .levelComplete:
            return ("Level Complete Sting", "wav")
        case .bossWarning:
            return ("Boss warning rumble", "mp3")
        case .bossHit:
            return ("Boss Hit", "wav")
        case .bossDefeated:
            return ("Boss defeated", "mp3")
        case .bossPhase:
            return ("Boss phase change", "mp3")
        case .buddingSplit:
            return ("Budding virus split", "wav")
        case .influenzaHit:
            return ("Influenza hit", "wav")
        case .influenzaReplicate:
            return ("Influenza replication bloom", "wav")
        case .playerDamage:
            return ("Player damage", "wav")
        case .playerDeath:
            return ("Player death", "mp3")
        case .plateletHit:
            return ("Platelet or clot bump-crack", "wav")
        case .pauseOpen:
            return ("Pause open", "wav")
        case .pauseResume:
            return ("Pause resume", "mp3")
        case .restartConfirm:
            return ("Restart confirmation open", "wav")
        case .upgradeHover:
            return ("Upgrade card hover", "wav")
        case .upgradeSelected:
            return ("Upgrade selected", "wav")
        case .uiSelect:
            return ("ui_button_select", "wav")
        }
    }

    var volume: Float {
        switch self {
        case .menu:
            return 0.42
        case .combat:
            return 0.36
        case .danger:
            return 0.46
        case .boss:
            return 0.40
        case .upgrade:
            return 0.34
        case .ambience:
            return 0.15
        case .shot:
            return 0.52
        case .upgradeHover:
            return 0.34
        case .bossWarning, .bossHit, .bossDefeated, .bossPhase, .buddingSplit, .influenzaHit, .influenzaReplicate, .playerDeath:
            return 0.62
        case .hit, .pop, .swimSurge, .dash, .pulse, .levelComplete, .playerDamage, .plateletHit, .pauseOpen, .pauseResume, .restartConfirm, .upgradeSelected, .uiSelect:
            return 0.62
        }
    }

    var isMusic: Bool {
        switch self {
        case .menu, .combat, .danger, .boss, .upgrade:
            return true
        default:
            return false
        }
    }
}

private final class AudioSystem {
    private var currentMusic: AVAudioPlayer?
    private var currentMusicCue: AudioCue?
    private var ambiencePlayer: AVAudioPlayer?
    private var sfxPlayers: [AudioCue: AVAudioPlayer] = [:]
    private var sfxPlaybackTokens: [AudioCue: Int] = [:]
    private var pausedSFX = Set<AudioCue>()
    private var musicMuted = false
    private var sfxMuted = false

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        AudioCue.allCases.filter { !$0.isMusic && $0 != .ambience }.forEach { cue in
            if let player = makePlayer(for: cue, loops: false) {
                sfxPlayers[cue] = player
            }
        }
        ambiencePlayer = makePlayer(for: .ambience, loops: true)
    }

    func playMusic(_ cue: AudioCue) {
        guard cue.isMusic, !musicMuted else {
            return
        }
        if currentMusicCue == cue, currentMusic?.isPlaying == true {
            return
        }
        currentMusic?.stop()
        currentMusic = makePlayer(for: cue, loops: true)
        currentMusicCue = cue
        currentMusic?.play()
    }

    func stopMusic() {
        currentMusic?.stop()
        currentMusic = nil
        currentMusicCue = nil
    }

    func pauseMusic() {
        currentMusic?.pause()
    }

    func resumeMusic() {
        guard !musicMuted else {
            return
        }
        currentMusic?.play()
    }

    func playAmbience() {
        guard !musicMuted, let ambiencePlayer else {
            return
        }
        if !ambiencePlayer.isPlaying {
            ambiencePlayer.currentTime = 0
            ambiencePlayer.play()
        }
    }

    func stopAmbience() {
        ambiencePlayer?.stop()
    }

    func setMusicMuted(_ muted: Bool) {
        musicMuted = muted
        if muted {
            stopMusic()
            stopAmbience()
        }
    }

    func setSFXMuted(_ muted: Bool) {
        sfxMuted = muted
        if muted {
            pausedSFX.removeAll()
            sfxPlayers.forEach { cue, player in
                _ = nextSFXPlaybackToken(for: cue)
                player.stop()
                player.currentTime = 0
                player.volume = cue.volume
            }
        }
    }

    func playSFX(_ cue: AudioCue) {
        guard !sfxMuted, let player = sfxPlayers[cue] else {
            return
        }
        _ = nextSFXPlaybackToken(for: cue)
        pausedSFX.remove(cue)
        player.stop()
        player.currentTime = 0
        player.volume = cue.volume
        player.play()
    }

    func playSFX(_ cue: AudioCue, fadeOutAfter delay: TimeInterval, fadeDuration: TimeInterval) {
        guard !sfxMuted, let player = sfxPlayers[cue] else {
            return
        }
        let token = nextSFXPlaybackToken(for: cue)
        pausedSFX.remove(cue)
        player.stop()
        player.currentTime = 0
        player.volume = cue.volume
        player.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + max(0, delay)) { [weak self, weak player] in
            guard let self,
                  let player,
                  self.sfxPlaybackTokens[cue] == token,
                  player.isPlaying else {
                return
            }
            player.setVolume(0, fadeDuration: fadeDuration)
            DispatchQueue.main.asyncAfter(deadline: .now() + max(0, fadeDuration)) { [weak self, weak player] in
                guard let self,
                      let player,
                      self.sfxPlaybackTokens[cue] == token else {
                    return
                }
                player.stop()
                player.currentTime = 0
                player.volume = cue.volume
            }
        }
    }

    func pauseSFX(_ cue: AudioCue) {
        guard let player = sfxPlayers[cue], player.isPlaying else {
            pausedSFX.remove(cue)
            return
        }
        player.pause()
        pausedSFX.insert(cue)
    }

    func resumeSFX(_ cue: AudioCue) {
        guard !sfxMuted,
              pausedSFX.remove(cue) != nil,
              let player = sfxPlayers[cue] else {
            return
        }
        player.volume = cue.volume
        player.play()
    }

    func stopSFX(_ cue: AudioCue) {
        guard let player = sfxPlayers[cue] else {
            return
        }
        _ = nextSFXPlaybackToken(for: cue)
        pausedSFX.remove(cue)
        player.stop()
        player.currentTime = 0
        player.volume = cue.volume
    }

    private func nextSFXPlaybackToken(for cue: AudioCue) -> Int {
        let token = (sfxPlaybackTokens[cue] ?? 0) + 1
        sfxPlaybackTokens[cue] = token
        return token
    }

    private func makePlayer(for cue: AudioCue, loops: Bool) -> AVAudioPlayer? {
        let file = cue.file
        guard let url = Bundle.main.url(forResource: file.name, withExtension: file.extension, subdirectory: "Assets/audio"),
              let player = try? AVAudioPlayer(contentsOf: url) else {
            return nil
        }
        player.numberOfLoops = loops ? -1 : 0
        player.volume = cue.volume
        player.prepareToPlay()
        return player
    }
}

private func clamp(_ value: CGFloat, _ minimum: CGFloat, _ maximum: CGFloat) -> CGFloat {
    min(max(value, minimum), maximum)
}

private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    hypot(a.x - b.x, a.y - b.y)
}

private func distanceSquared(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let dx = a.x - b.x
    let dy = a.y - b.y
    return dx * dx + dy * dy
}

private func vectorLength(_ vector: CGVector) -> CGFloat {
    hypot(vector.dx, vector.dy)
}

private func normalized(_ vector: CGVector) -> CGVector {
    let length = vectorLength(vector)
    guard length > 0.001 else {
        return .zero
    }
    return CGVector(dx: vector.dx / length, dy: vector.dy / length)
}

private func limit(_ vector: CGVector, maxLength: CGFloat) -> CGVector {
    let length = vectorLength(vector)
    guard length > maxLength, length > 0.001 else {
        return vector
    }
    let scale = maxLength / length
    return CGVector(dx: vector.dx * scale, dy: vector.dy * scale)
}

private func lerp(_ from: CGVector, _ to: CGVector, _ amount: CGFloat) -> CGVector {
    CGVector(dx: from.dx + (to.dx - from.dx) * amount, dy: from.dy + (to.dy - from.dy) * amount)
}

private extension CGFloat {
    static func lerp(from: CGFloat, to: CGFloat, amount: CGFloat) -> CGFloat {
        from + (to - from) * amount
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }

    func positiveModulo(_ divisor: Int) -> Int {
        guard divisor > 0 else {
            return 0
        }
        let result = self % divisor
        return result >= 0 ? result : result + divisor
    }
}

private func rotated(_ vector: CGVector, radians: CGFloat) -> CGVector {
    let c = cos(radians)
    let s = sin(radians)
    return CGVector(dx: vector.dx * c - vector.dy * s, dy: vector.dx * s + vector.dy * c)
}

private func angle(for vector: CGVector) -> CGFloat {
    atan2(-vector.dy, vector.dx)
}
