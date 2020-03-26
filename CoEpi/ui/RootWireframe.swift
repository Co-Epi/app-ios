import Dip
import UIKit

class RootWireFrame {
    private let container: DependencyContainer

    private var homeViewController: HomeViewController?
    private var onboardingWireframe: OnboardingWireframe?
    private var rootNavigationController = UINavigationController()

    init(container: DependencyContainer, window: UIWindow) {
        self.container = container
        let showOnboarding = true

        let homeViewModel: HomeViewModel = try! container.resolve()
        homeViewModel.delegate = self
        
        let homeViewController = HomeViewController(viewModel: homeViewModel)
        rootNavigationController.setViewControllers([homeViewController], animated: false)
        
        window.rootViewController = rootNavigationController
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
    
    func checkInTapped() {
        showQuiz()
    }
    
    private func showQuiz() {
        let quizViewController = HealthQuizViewController.init(nibName: String(describing:HealthQuizViewController.self), bundle: nil
        )
        quizViewController.title = "My Health"
        rootNavigationController.pushViewController(quizViewController, animated: true)
    }
    
    func seeAlertsTapped(){
        showAlerts()
    }
    
    private func showAlerts(){
        let alertsViewController = AlertsViewController.init(nibName: String(describing:AlertsViewController.self), bundle: nil
               )
               alertsViewController.title = "Alerts"
               rootNavigationController.pushViewController(alertsViewController, animated: true)
        
    }
}
