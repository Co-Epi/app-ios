import UIKit
import SwiftUI


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var rootWireframe: RootWireFrame?

    lazy var container = (UIApplication.shared.delegate as! AppDelegate).container

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            rootWireframe = RootWireFrame(container: container, window: window)
            self.window = window
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        let badgeUpdater: AppBadgeUpdater = try! container.resolve()
        badgeUpdater.updateAppBadge(number: 0)
    }
}
