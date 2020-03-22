import Dip
import UIKit

class RootWireFrame {
    private var onboardingWireframe: OnboardingWireframe?
    
    init(container: DependencyContainer, window: UIWindow) {
        let showOnboarding = true

        let home = HomeViewController()
        window.rootViewController = home
        window.makeKeyAndVisible()

        if showOnboarding {
            let wireFrame: OnboardingWireframe = try! container.resolve()
            wireFrame.showIfNeeded(parent: home)
            onboardingWireframe = wireFrame
        }
    }
}
