import Dip
import RxCocoa
import RxSwift
import os.log

class AlertsViewModel {
    private let alertRepo: AlertRepo

    let title: Driver<String>
    let alerts: Driver<[AlertViewData]>
    let updateStatusText: Driver<String>

    init(alertRepo: AlertRepo) {
        self.alertRepo = alertRepo

        title = alertRepo.alerts
            .map { AlertsViewModel.formatTitleLabel(count: $0.count) }
            .startWith(AlertsViewModel.formatTitleLabel(count: 0))
            .asDriver(onErrorJustReturn: "Alerts")

        alerts = alertRepo.alerts
            .map { alerts in alerts.map { $0.toViewData() }}
            .asDriver(onErrorJustReturn: [])

        updateStatusText = alertRepo.updateReportsState
            .do(onNext: { result in
                os_log("Got alerts result in view model: %{public}@", log: servicesLog, type: .debug, "\(result)")
            })
            .filter { $0.shouldBeShown() }
            .map { $0.asText() }
            .asDriver(onErrorJustReturn: "Unknown error")
    }

    func updateReports() {
        alertRepo.updateReports()
    }

    func acknowledge(alert: AlertViewData) {
        alertRepo.removeAlert(alert: alert.alert)
    }

    private static func formatTitleLabel(count: Int) -> String {
        switch count {
        case 0: return L10n.Alerts.Count.none
        case 1: return L10n.Alerts.Count.one
        default: return L10n.Alerts.Count.some(count)
        }
    }
}

private extension Alert {
    func toViewData() -> AlertViewData {
        AlertViewData(
            symptoms: exposure.isEmpty ? L10n.Alerts.Label.noSymptomsReported : exposure,
            time: DateFormatters.dateHoursMins.string(from: timestamp.toDate()),
            alert: self
        )
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
