import Dip
import RxCocoa
import RxSwift

class AlertsViewModel {
    private let alertRepo: AlertRepo

    private(set) var title: Driver<String>
    private(set) var alerts: Driver<[Alert]>
    
    init(container: DependencyContainer) {
        self.alertRepo = try! container.resolve()

        title = alertRepo.alerts
            .map { AlertsViewModel.formatTitleLabel(count: $0.count) }
            .startWith(AlertsViewModel.formatTitleLabel(count: 0))
            .asDriver(onErrorJustReturn: "Alerts")

        alerts = alertRepo.alerts.asDriver(onErrorJustReturn: [])
    }

    private static func formatTitleLabel(count: Int) -> String {
        let title: String = "\(count) new contact alert"
        
        if count < 2 {
            return title
        }
        return title + "s"
    }

    public func acknowledge(alert: Alert) {
        alertRepo.removeAlert(alert: alert)
    }
}
