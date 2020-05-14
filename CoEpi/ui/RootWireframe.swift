import Dip
import UIKit
import RxSwift

class RootWireFrame {
    private let container: DependencyContainer

    private var homeViewController: HomeViewController?
    private var rootNavigationController = UINavigationController()
    private var onboardingWireframe: OnboardingWireframe?

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
        case .thankYou: showThankYou()
        case .breathless: showBreathless()
        case .coughType: showCoughType()
        case .coughDays: showCoughDays()
        case .coughHow: showCoughHow()
        case .feverDays: showFeverDays()
        case .feverToday: showFeverToday()
        case .feverWhere: showFeverWhere()
        case .feverWhereOther: showFeverWhereOther()
        case .feverTemp: showFeverTemp()
        case .symptomReport: showSymptomReport()
        case .onboarding: showOnboarding()
        case .SymptomStartDays: showSymptomStartDays()
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
    
    private func showThankYou() {
        let viewModel: ThankYouViewModel = try! container.resolve()
        let thankYouViewController = ThankYouViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(thankYouViewController, animated: true)
    }
    
    private func showBreathless() {
        let viewModel: BreathlessViewModel = try! container.resolve()
        let breathlessViewController = BreathlessViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(breathlessViewController, animated: true)
    }
    
    private func showCoughType() {
        let viewModel: CoughTypeViewModel = try! container.resolve()
        let coughTypeViewController = CoughTypeViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(coughTypeViewController, animated: true)
    }

    private func showCoughDays() {
        let viewModel: CoughDaysViewModel = try! container.resolve()
        let coughDaysViewController = CoughDaysViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(coughDaysViewController, animated: true)
    }
    
    private func showCoughHow() {
        let viewModel: CoughHowViewModel = try! container.resolve()
        let coughHowViewController = CoughHowViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(coughHowViewController, animated: true)
    }
    
    private func showFeverDays() {
        let viewModel: FeverDaysViewModel = try! container.resolve()
        let feverDaysViewController = FeverDaysViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(feverDaysViewController, animated: true)
    }
    
    private func showFeverToday() {
        let viewModel: FeverTodayViewModel = try! container.resolve()
        let feverTodayViewController = FeverTodayViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(feverTodayViewController, animated: true)
    }
    
    private func showFeverWhere() {
        let viewModel: FeverWhereViewModel = try! container.resolve()
        let feverWhereViewController = FeverWhereViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(feverWhereViewController, animated: true)
    }
    
    private func showFeverWhereOther() {
        let viewModel: FeverWhereViewModelOther = try! container.resolve()
        let feverWhereViewControllerOther = FeverWhereViewControllerOther(viewModel: viewModel)
        rootNavigationController.pushViewController(feverWhereViewControllerOther, animated: true)
    }
    
    private func showFeverTemp() {
        let viewModel: FeverTempViewModel = try! container.resolve()
        let feverTempViewController = FeverTempViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(feverTempViewController, animated: true)
    }
    
    private func showSymptomReport() {
        let viewModel: SymptomReportViewModel = try! container.resolve()
        let symptomReportViewController = SymptomReportViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(symptomReportViewController, animated: true)
    }
    
    private func showOnboarding() {
        let viewModel: OnboardingViewModel = try! container.resolve()
        let onboardingViewController = OnboardingViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(onboardingViewController, animated: true)
    }
    
    private func showSymptomStartDays() {
        let viewModel: SymptomStartDaysViewModel = try! container.resolve()
        let symptomStartDaysViewController = SymptomStartDaysViewController(viewModel: viewModel)
        rootNavigationController.pushViewController(symptomStartDaysViewController, animated: true)
    }
    
}
