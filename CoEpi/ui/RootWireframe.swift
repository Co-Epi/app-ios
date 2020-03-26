import Dip
import UIKit

class RootWireFrame {
    private let container: DependencyContainer

    private var homeViewController: HomeViewController?
    private var onboardingWireframe: OnboardingWireframe?

    init(container: DependencyContainer, window: UIWindow) {
        self.container = container
        let showOnboarding = true

        let homeViewModel: HomeViewModel = try! container.resolve()
        homeViewModel.delegate = self
        
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        window.rootViewController = homeViewController
        window.makeKeyAndVisible()

        self.homeViewController = homeViewController

        if showOnboarding {
            let wireFrame: OnboardingWireframe = try! container.resolve()
            wireFrame.showIfNeeded(parent: homeViewController)
            onboardingWireframe = wireFrame
        }
    }
}

extension RootWireFrame : HomeViewModelDelegate {
    func debugTapped() {
        showDebug()
    }

    private func showDebug() {
        let debugViewModel: DebugViewModel = try! container.resolve()

        let debugViewController = DebugViewController(viewModel: debugViewModel)
        homeViewController?.present(debugViewController, animated: true, completion: nil)
    }
}
