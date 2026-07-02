import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    private weak var gameScene: GameScene?
    private var combatControlsOverlay: CombatGlassControlsOverlayView?
    private var didPresentScene = false

    override func loadView() {
        let skView = SKView(frame: .zero)
        skView.backgroundColor = .black
        skView.ignoresSiblingOrder = true
        skView.isMultipleTouchEnabled = true
        skView.preferredFramesPerSecond = 60
        view = skView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didPresentScene, let skView = view as? SKView else {
            combatControlsOverlay?.frame = view.bounds
            combatControlsOverlay?.setNeedsLayout()
            return
        }

        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        gameScene = scene
        didPresentScene = true
        installCombatControlsOverlayIfAvailable(on: skView, scene: scene)
        becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        true
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .landscape
    }

    func applicationWillResignActive() {
        gameScene?.applicationWillResignActive()
    }

    func applicationDidEnterBackground() {
        gameScene?.applicationDidEnterBackground()
    }

    func applicationWillEnterForeground() {
        gameScene?.applicationWillEnterForeground()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var handled = false
        for press in presses {
            if let keyCode = press.key?.keyCode {
                gameScene?.setKey(keyCode, isPressed: true)
                handled = true
            }
        }
        if !handled {
            super.pressesBegan(presses, with: event)
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var handled = false
        for press in presses {
            if let keyCode = press.key?.keyCode {
                gameScene?.setKey(keyCode, isPressed: false)
                handled = true
            }
        }
        if !handled {
            super.pressesEnded(presses, with: event)
        }
    }

    private func installCombatControlsOverlayIfAvailable(on skView: SKView, scene: GameScene) {
        guard #available(iOS 26.0, *) else {
            return
        }

        let overlay = CombatGlassControlsOverlayView(frame: skView.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.onDash = { [weak scene] in
            scene?.performNativeDashButtonPress()
        }
        overlay.onPulse = { [weak scene] in
            scene?.performNativePulseButtonPress()
        }
        skView.addSubview(overlay)
        combatControlsOverlay = overlay
        scene.combatControlsDelegate = self
        scene.setNativeCombatAbilityControlsAvailable(true)
    }
}

extension GameViewController: GameSceneCombatControlsDelegate {
    func gameScene(_ scene: GameScene, didUpdateCombatAbilityControls state: CombatAbilityControlState) {
        combatControlsOverlay?.apply(state)
    }
}

private final class CombatGlassControlsOverlayView: UIView {
    var onDash: (() -> Void)?
    var onPulse: (() -> Void)?

    private let baseSize = CGSize(width: 1280, height: 720)
    private let dashCenter = CGPoint(x: 1118, y: 535)
    private let pulseCenter = CGPoint(x: 1118, y: 633)
    private let buttonSize = CGSize(width: 224, height: 86)
    private let buttonHostView = UIView()
    private let dashButton = GlassAbilityButton(accessibilityName: "Dash")
    private let pulseButton = GlassAbilityButton(accessibilityName: "Pulse")
    private var currentScale: CGFloat = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isHidden = true
        buttonHostView.backgroundColor = .clear
        buttonHostView.isUserInteractionEnabled = true
        addSubview(buttonHostView)
        buttonHostView.addSubview(dashButton)
        buttonHostView.addSubview(pulseButton)
        dashButton.addTarget(self, action: #selector(didTapDash), for: .touchUpInside)
        pulseButton.addTarget(self, action: #selector(didTapPulse), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        buttonHostView.frame = bounds

        let scale = min(bounds.width / baseSize.width, bounds.height / baseSize.height)
        let origin = CGPoint(
            x: max(0, (bounds.width - baseSize.width * scale) * 0.5),
            y: max(0, (bounds.height - baseSize.height * scale) * 0.5)
        )
        currentScale = scale
        dashButton.frame = frameForButton(center: dashCenter, origin: origin, scale: scale).integral
        pulseButton.frame = frameForButton(center: pulseCenter, origin: origin, scale: scale).integral
        dashButton.updateLayout(scale: scale)
        pulseButton.updateLayout(scale: scale)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard !isHidden, alpha > 0.01 else {
            return false
        }
        let dashPoint = dashButton.convert(point, from: self)
        if dashButton.point(inside: dashPoint, with: event) {
            return true
        }
        let pulsePoint = pulseButton.convert(point, from: self)
        return pulseButton.point(inside: pulsePoint, with: event)
    }

    func apply(_ state: CombatAbilityControlState) {
        isHidden = !state.isVisible
        dashButton.configure(
            title: state.dashTitle,
            isEnabled: state.dashEnabled,
            isReady: state.dashReady,
            isUnlocked: state.dashUnlocked
        )
        pulseButton.configure(
            title: state.pulseTitle,
            isEnabled: state.pulseEnabled,
            isReady: state.pulseReady,
            isUnlocked: state.pulseUnlocked
        )
        dashButton.updateLayout(scale: currentScale)
        pulseButton.updateLayout(scale: currentScale)
    }

    private func frameForButton(center: CGPoint, origin: CGPoint, scale: CGFloat) -> CGRect {
        CGRect(
            x: origin.x + (center.x - buttonSize.width * 0.5) * scale,
            y: origin.y + (center.y - buttonSize.height * 0.5) * scale,
            width: buttonSize.width * scale,
            height: buttonSize.height * scale
        )
    }

    @objc private func didTapDash() {
        onDash?()
    }

    @objc private func didTapPulse() {
        onPulse?()
    }
}

private final class GlassAbilityButton: UIButton {
    private var abilityTitle = ""
    private var currentScale: CGFloat = 1
    private var isReadyState = false
    private var isUnlockedState = false

    init(accessibilityName: String) {
        super.init(frame: .zero)
        backgroundColor = .clear
        clipsToBounds = false
        isAccessibilityElement = true
        accessibilityLabel = accessibilityName
        accessibilityTraits = [.button]
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.68
        titleLabel?.numberOfLines = 1
        titleLabel?.lineBreakMode = .byClipping
        titleLabel?.allowsDefaultTighteningForTruncation = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.10, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
                self.alpha = self.isHighlighted ? 0.86 : 1.0
            }
        }
    }

    func configure(title: String, isEnabled: Bool, isReady: Bool, isUnlocked: Bool) {
        abilityTitle = title
        accessibilityValue = title
        accessibilityTraits = isEnabled ? [.button] : [.button, .notEnabled]
        self.isEnabled = true
        isReadyState = isReady
        isUnlockedState = isUnlocked
        applyStateAppearance()
    }

    func updateLayout(scale: CGFloat) {
        currentScale = scale
        applyStateAppearance()
    }

    private func applyStateAppearance() {
        var nextConfiguration: UIButton.Configuration
        if #available(iOS 26.0, *) {
            nextConfiguration = isReadyState ? .prominentClearGlass() : .clearGlass()
        } else {
            nextConfiguration = .bordered()
        }
        nextConfiguration.title = abilityTitle
        nextConfiguration.buttonSize = .large
        nextConfiguration.cornerStyle = .capsule
        nextConfiguration.titleAlignment = .center
        nextConfiguration.titleLineBreakMode = .byClipping
        nextConfiguration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: max(12, 18 * currentScale),
            bottom: 0,
            trailing: max(12, 18 * currentScale)
        )
        nextConfiguration.baseForegroundColor = isReadyState
            ? UIColor(red: 1.0, green: 0.88, blue: 0.36, alpha: 1.0)
            : UIColor.white.withAlphaComponent(isUnlockedState ? 0.96 : 0.70)
        nextConfiguration.baseBackgroundColor = nil
        configuration = nextConfiguration
    }
}
