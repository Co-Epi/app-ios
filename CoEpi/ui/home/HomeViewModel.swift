import RxSwift
import os.log

class HomeViewModel {
    let title = L10n.Ux.Home.title

    private let disposeBag = DisposeBag()

    private let rootNav: RootNav

    init(startPermissions: StartPermissions, rootNav: RootNav) {
        self.rootNav = rootNav

        startPermissions.granted.subscribe(onNext: { granted in
            os_log("Start permissions granted: %{public}@", log: servicesLog, type: .debug, "\(granted)")
        }).disposed(by: disposeBag)

        startPermissions.request()
    }

    func debugTapped() {
        rootNav.navigate(command: .to(destination: .debug))
    }

    func quizTapped() {
//        rootNav.navigate(command: .to(destination: .quiz))
        rootNav.navigate(command: .to(destination: .symptomReport))
    }

    func seeAlertsTapped() {
        rootNav.navigate(command: .to(destination: .alerts))
    }
}
