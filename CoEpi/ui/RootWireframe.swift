import Dip
import UIKit
import RxSwift

class RootWireFrame {
    private let container: DependencyContainer

    private var homeViewController: HomeViewController?
    private var onboardingWireframe: OnboardingWireframe?
    private var rootNavigationController = UINavigationController()

    private let disposeBag = DisposeBag()

    init(container: DependencyContainer, window: UIWindow) {
        self.container = container

        initNav()

        let homeViewModel: HomeViewModel = try! container.resolve()

        let homeViewController = HomeViewController(viewModel: homeViewModel)
        rootNavigationController.setViewControllers([homeViewController], animated: false)
        
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()

        self.homeViewController = homeViewController

        let keyValueStore: KeyValueStore = try! container.resolve()
        showOnboardingIfNeeded(keyValueStore: keyValueStore, parent: homeViewController)
    }

    private func initNav() {
        let rootNav: RootNav = try! container.resolve()

        rootNav.navigationCommands.subscribe(onNext: { [weak self] command in
            self?.onNavigationCommand(navCommand: command)
        }).disposed(by: disposeBag)
    }

    private func showOnboardingIfNeeded(keyValueStore: KeyValueStore, parent: UIViewController) {
        guard !keyValueStore.getBool(key: .seenOnboarding) else {
            return
        }

        let wireFrame: OnboardingWireframe = try! container.resolve()
        wireFrame.showIfNeeded(parent: parent)
        onboardingWireframe = wireFrame
        keyValueStore.putBool(key: .seenOnboarding, value: true)
    }

    private func onNavigationCommand(navCommand: RootNavCommand) {
        switch navCommand {
        case .to(let destination): navigate(to: destination)
        case .back: rootNavigationController.popViewController(animated: true)
        }
    }

    private func navigate(to: RootNavDestination) {
        switch to {
        case .quiz: showQuiz()
        case .debug: showDebug()
        case .alerts: showAlerts()
        }
    }

    private func showDebug() {
        let debugViewModel: DebugViewModel = try! container.resolve()
        let debugViewController = DebugViewController(viewModel: debugViewModel)
        rootNavigationController.pushViewController(debugViewController, animated: true)
    }


    private func showQuiz() {
        let viewModel: HealthQuizViewModel = try! container.resolve()
        let quizViewController = HealthQuizViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(quizViewController, animated: true)
    }

    private func showAlerts() {
        let viewModel: AlertsViewModel = try! container.resolve()
        let alertsViewController = AlertsViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(alertsViewController, animated: true)
    }
}
