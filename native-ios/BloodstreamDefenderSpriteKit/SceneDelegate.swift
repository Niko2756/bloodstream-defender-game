import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var gameViewController: GameViewController? {
        window?.rootViewController as? GameViewController
    }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = GameViewController()
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneWillResignActive(_ scene: UIScene) {
        gameViewController?.applicationWillResignActive()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        gameViewController?.applicationDidEnterBackground()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        gameViewController?.applicationWillEnterForeground()
    }
}
