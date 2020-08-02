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
            let viewController = self.viewController(for: destination)
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

    private func viewController(for destination: RootNavDestination) -> UIViewController {
        switch destination {
        case .debug: return debug()
        case .alerts: return alerts()
        case .thankYou: return thankYou()
        case .breathless: return breathless()
        case .coughType: return coughType()
        case .coughDescription: return coughHow()
        case .feverTemperatureTakenToday: return feverToday()
        case .feverTemperatureSpot: return feverWhere()
        case .feverHighestTemperature: return feverTemp()
        case .symptomReport: return symptomReport()
        case .symptomStartDays: return symptomStartDays()
        case .home: return home()
        case let .alertDetails(pars): return alertDetails(pars: pars)
        case .settings: return settings()
        case .howItWorks: return howItWorks()
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

    private func navigateBack(to destination: RootNavDestination) {
        rootNavigationController.backToViewController(
            type: viewControllerTypeFor(destination: destination))
    }

    private func navigate(to destination: RootNavDestination) {
        rootNavigationController.pushViewController(
            viewController(for: destination), animated: true)
    }

    private func navigateBackAndTo(
        backDestination: RootNavDestination,
        toDestination: RootNavDestination
    ) {
        navigateBack(to: backDestination)
        navigate(to: toDestination)
    }

    private func home() -> UIViewController {
        let viewModel: HomeViewModel = try! container.resolve()
        return HomeViewController(viewModel: viewModel)
    }

    private func debug() -> UIViewController {
        DebugViewController(container: container)
    }

    private func alerts() -> UIViewController {
        let viewModel: AlertsViewModel = try! container.resolve()
        return AlertsViewController(viewModel: viewModel)
    }

    private func thankYou() -> UIViewController {
        let viewModel: ThankYouViewModel = try! container.resolve()
        return ThankYouViewController(viewModel: viewModel)
    }

    private func breathless() -> UIViewController {
        let viewModel: BreathlessViewModel = try! container.resolve()
        return BreathlessViewController(viewModel: viewModel)
    }

    private func coughType() -> UIViewController {
        let viewModel: CoughTypeViewModel = try! container.resolve()
        return CoughTypeViewController(viewModel: viewModel)
    }

    private func coughDays() -> UIViewController {
        let viewModel: CoughDaysViewModel = try! container.resolve()
        return CoughDaysViewController(viewModel: viewModel)
    }

    private func coughHow() -> UIViewController {
        let viewModel: CoughHowViewModel = try! container.resolve()
        return CoughHowViewController(viewModel: viewModel)
    }

    private func feverDays() -> UIViewController {
        let viewModel: FeverDaysViewModel = try! container.resolve()
        return FeverDaysViewController(viewModel: viewModel)
    }

    private func feverToday() -> UIViewController {
        let viewModel: FeverTodayViewModel = try! container.resolve()
        return FeverTodayViewController(viewModel: viewModel)
    }

    private func feverWhere() -> UIViewController {
        let viewModel: FeverWhereViewModel = try! container.resolve()
        return FeverWhereViewController(viewModel: viewModel)
    }

    private func feverTemp() -> UIViewController {
        let viewModel: FeverTempViewModel = try! container.resolve()
        return FeverTempViewController(viewModel: viewModel)
    }

    private func symptomReport() -> UIViewController {
        let viewModel: SymptomReportViewModel = try! container.resolve()
        return SymptomReportViewController(viewModel: viewModel)
    }

    private func symptomStartDays() -> UIViewController {
        let viewModel: SymptomStartDaysViewModel = try! container.resolve()
        return SymptomStartDaysViewController(viewModel: viewModel)
    }

    private func alertDetails(pars: AlertDetailsViewModelParams) -> UIViewController {
        let viewModel: AlertDetailsViewModel = try! container.resolve(arguments: pars)
        return AlertDetailsViewController(viewModel: viewModel)
    }

    private func settings() -> UIViewController {
        let viewModel: UserSettingsViewModel = try! container.resolve()
        return UserSettingsViewController(viewModel: viewModel)
    }

    private func howItWorks() -> UIViewController {
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
