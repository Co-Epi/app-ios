import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var rootWireframe: RootWireFrame?

    lazy var container = (UIApplication.shared.delegate as! AppDelegate).container

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            rootWireframe = RootWireFrame(container: container, window: window)
            self.window = window
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        let badgeUpdater: AppBadgeUpdater = try! container.resolve()
        badgeUpdater.updateAppBadge(number: 0)

        let localeProvider: LocaleProvider = try! container.resolve()
        localeProvider.update()
    }
}
