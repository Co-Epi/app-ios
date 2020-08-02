import Dip
import RxSwift
import UIKit

class RootWireFrame {
    private let container: DependencyContainer

    private var homeViewController: HomeViewController?
    private var rootNavigationController = UINavigationController()
    private var onboardingWireframe: OnboardingWireframe?

    private let disposeBag = DisposeBag()

    private var symptomFlowManager: SymptomFlowManager?

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
        wireFrame.showOnboarding(parent: parent)
        onboardingWireframe = wireFrame
        keyValueStore.putBool(key: .seenOnboarding, value: true)
    }

    private func onNavigationCommand(navCommand: RootNavCommand) {
        switch navCommand {
        case let .to(destination, mode):
            let viewController = navigate(to: destination)
            switch mode {
            case .push: rootNavigationController.pushViewController(
                viewController, animated: true
            )
            case .modal: rootNavigationController.present(
                viewController, animated: true, completion: nil
            )
            }
        case .back: rootNavigationController.popViewController(animated: true)
        case let .backTo(destination): navigateBack(to: destination)
        case let .backToAndTo(backDestination, toDestination):
            navigateBackAndTo(backDestination: backDestination, toDestination: toDestination)
        }
    }

    private func navigate(to: RootNavDestination) -> UIViewController {
        switch to {
        case .debug: return showDebug()
        case .alerts: return showAlerts()
        case .thankYou: return showThankYou()
        case .breathless: return showBreathless()
        case .coughType: return showCoughType()
        case .coughDescription: return showCoughHow()
        case .feverTemperatureTakenToday: return showFeverToday()
        case .feverTemperatureSpot: return showFeverWhere()
        case .feverHighestTemperature: return showFeverTemp()
        case .symptomReport: return showSymptomReport()
        case .symptomStartDays: return showSymptomStartDays()
        case .home: return showHome()
        case let .alertDetails(pars): return showAlertDetails(pars: pars)
        case .settings: return showSettings()
        case .howItWorks: return showHowItWorks()
        }
    }

    private func clear(until _: RootNavDestination) {
        let type = HomeViewController.self
        rootNavigationController.clearNavigationUntil(type: type)
    }

    private func viewControllerTypeFor(destination: RootNavDestination) -> UIViewController.Type {
        switch destination {
        case .debug: return DebugViewController.self
        case .alerts: return AlertsViewController.self
        case .thankYou: return ThankYouViewController.self
        case .breathless: return BreathlessViewController.self
        case .coughType: return CoughTypeViewController.self
        case .coughDescription: return CoughHowViewController.self
        case .feverTemperatureTakenToday: return FeverTodayViewController.self
        case .feverTemperatureSpot: return FeverWhereViewController.self
        case .feverHighestTemperature: return FeverTempViewController.self
        case .symptomReport: return SymptomReportViewController.self
        case .symptomStartDays: return SymptomStartDaysViewController.self
        case .home: return HomeViewController.self
        case .alertDetails: return AlertDetailsViewController.self
        case .settings: return UserSettingsViewController.self
        case .howItWorks: return WhatAreAlertsViewController.self
        }
    }

    private func navigateBack(to: RootNavDestination) {
        rootNavigationController.backToViewController(type: viewControllerTypeFor(destination: to))
    }

    private func navigateBackAndTo(
        backDestination: RootNavDestination,
        toDestination: RootNavDestination
    ) {
        navigateBack(to: backDestination)
        navigate(to: toDestination)
    }

    private func showHome() -> UIViewController {
        let viewModel: HomeViewModel = try! container.resolve()
        return HomeViewController(viewModel: viewModel)
    }

    private func showDebug() -> UIViewController {
        DebugViewController(container: container)
    }

    private func showAlerts() -> UIViewController {
        let viewModel: AlertsViewModel = try! container.resolve()
        return AlertsViewController(viewModel: viewModel)
    }

    private func showThankYou() -> UIViewController {
        let viewModel: ThankYouViewModel = try! container.resolve()
        return ThankYouViewController(viewModel: viewModel)
    }

    private func showBreathless() -> UIViewController {
        let viewModel: BreathlessViewModel = try! container.resolve()
        return BreathlessViewController(viewModel: viewModel)
    }

    private func showCoughType() -> UIViewController {
        let viewModel: CoughTypeViewModel = try! container.resolve()
        return CoughTypeViewController(viewModel: viewModel)
    }

    private func showCoughDays() -> UIViewController {
        let viewModel: CoughDaysViewModel = try! container.resolve()
        return CoughDaysViewController(viewModel: viewModel)
    }

    private func showCoughHow() -> UIViewController {
        let viewModel: CoughHowViewModel = try! container.resolve()
        return CoughHowViewController(viewModel: viewModel)
    }

    private func showFeverDays() -> UIViewController {
        let viewModel: FeverDaysViewModel = try! container.resolve()
        return FeverDaysViewController(viewModel: viewModel)
    }

    private func showFeverToday() -> UIViewController {
        let viewModel: FeverTodayViewModel = try! container.resolve()
        return FeverTodayViewController(viewModel: viewModel)
    }

    private func showFeverWhere() -> UIViewController {
        let viewModel: FeverWhereViewModel = try! container.resolve()
        return FeverWhereViewController(viewModel: viewModel)
    }

    private func showFeverTemp() -> UIViewController {
        let viewModel: FeverTempViewModel = try! container.resolve()
        return FeverTempViewController(viewModel: viewModel)
    }

    private func showSymptomReport() -> UIViewController {
        let viewModel: SymptomReportViewModel = try! container.resolve()
        return SymptomReportViewController(viewModel: viewModel)
    }

    private func showSymptomStartDays() -> UIViewController {
        let viewModel: SymptomStartDaysViewModel = try! container.resolve()
        return SymptomStartDaysViewController(viewModel: viewModel)
    }

    private func showAlertDetails(pars: AlertDetailsViewModelParams) -> UIViewController {
        let viewModel: AlertDetailsViewModel = try! container.resolve(arguments: pars)
        return AlertDetailsViewController(viewModel: viewModel)
    }

    private func showSettings() -> UIViewController {
        let viewModel: UserSettingsViewModel = try! container.resolve()
        return UserSettingsViewController(viewModel: viewModel)
    }

    private func showHowItWorks() -> UIViewController {
        WhatAreAlertsViewController()
    }
}

extension UINavigationController {
    func backToViewController<T: UIViewController>(type _: T.Type) {
        for element in viewControllers as Array where element is T {
            popToViewController(element, animated: true)
            break
        }
    }

    func clearNavigationUntil<T: UIViewController>(type _: T.Type) {
        for i in (0 ..< viewControllers.count).reversed() {
            if viewControllers[i] is T {
                return
            }
            viewControllers.remove(at: i)
        }
    }
}
