import RxSwift
import os.log

class HomeViewModel {
    let title = "CoEpi"

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
        rootNav.navigate(command: .to(destination: .quiz))
    }
    
    func seeAlertsTapped() {
        rootNav.navigate(command: .to(destination: .alerts))
    }
}
