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
        if count == 0 {
            return L10n.Alerts.Count.none
        }
        if count == 1 {
            return L10n.Alerts.Count.one
        }
        return L10n.Alerts.Count.some(count)
    }

    public func acknowledge(alert: Alert) {
        alertRepo.removeAlert(alert: alert)
    }
}
