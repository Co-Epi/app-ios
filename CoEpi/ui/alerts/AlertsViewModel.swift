import Dip
import RxCocoa
import RxSwift

class AlertsViewModel {
    private let alertRepo: AlertRepo

    private(set) var title: Driver<String>
    private(set) var alerts: Driver<[Alert]>
    
    init(container: DependencyContainer) {
        self.alertRepo = try! container.resolve()

        let titleString: String = AlertsViewModel.formatTitleLabel(count: alertRepo.alerts().count)
        title = Observable.just(titleString)
            .asDriver(onErrorJustReturn: "Alerts")

        alerts = Observable.just(alertRepo.alerts())
            .asDriver(onErrorJustReturn: [])
    }

    private static func formatTitleLabel(count: Int) -> String {
        let title: String = "\(count) new contact alert"
        
        if count < 2 {
            return title
        }
        return title + "s"
    }
}
