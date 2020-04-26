import Dip
import RxCocoa
import RxSwift

class AlertsViewModel {
    private let alertRepo: AlertRepo

    let title: Driver<String>
    let alerts: Driver<[Alert]>
    let updateStatusText: Driver<String>

    init(alertRepo: AlertRepo) {
        self.alertRepo = alertRepo

        title = alertRepo.alerts
            .map { AlertsViewModel.formatTitleLabel(count: $0.count) }
            .startWith(AlertsViewModel.formatTitleLabel(count: 0))
            .asDriver(onErrorJustReturn: "Alerts")

        alerts = alertRepo.alerts.asDriver(onErrorJustReturn: [])

        updateStatusText = alertRepo.updateReportsState
            .filter { $0.shouldBeShown() }
            .map { $0.asText() }
            .asDriver(onErrorJustReturn: "Unknown error")
    }

    func updateReports() {
        alertRepo.updateReports()
    }

    func acknowledge(alert: Alert) {
        alertRepo.removeAlert(alert: alert)
    }

    private static func formatTitleLabel(count: Int) -> String {
        switch count {
        case 0: return L10n.Alerts.Count.none
        case 1: return L10n.Alerts.Count.one
        default: return L10n.Alerts.Count.some(count)
        }
    }
}

private extension OperationState where T == CenReportUpdateResult {

    func shouldBeShown() -> Bool {
        switch self {
        case .progress, .failure, .success: return true
        case .notStarted: return false
        }
    }

    // NOTE: Not localized. At the moment it's only for testing.
    func asText() -> String {
        switch self {
        case .notStarted, .success: return ""
        case .progress: return "Updating..."
        case .failure(let error): return "Error updating: \(error)"
        }
    }
}
