import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    private weak var gameScene: GameScene?
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
            return
        }

        let scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        gameScene = scene
        didPresentScene = true
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
}
