import Dip
import RxCocoa
import RxSwift
import os.log

class AlertsViewModel {
    private let alertRepo: AlertRepo

    let alerts: Driver<[AlertViewData]>
    let updateStatusText: Driver<String>

    init(alertRepo: AlertRepo) {
        self.alertRepo = alertRepo

        alerts = alertRepo.alerts
            .map { alerts in alerts.map { $0.toViewData() }}
            .asDriver(onErrorJustReturn: [])

        updateStatusText = alertRepo.updateReportsState
            .do(onNext: { result in
                os_log("Got alerts result in view model: %{public}@", log: servicesLog, type: .debug, "\(result)")
            })
            .filter { $0.shouldShowText() }
            .map { $0.asText() }
            .asDriver(onErrorJustReturn: "Unknown error")
    }

    func updateReports() {
        alertRepo.updateReports()
    }

    func acknowledge(alert: AlertViewData) {
        alertRepo.removeAlert(alert: alert.alert)
    }
}

private extension FeverSeverity {
    func toLocalizedName() -> String {
        switch self {
        case .Mild: return L10n.Alerts.Label.Fever.mild
        case .Serious: return L10n.Alerts.Label.Fever.serious
        case .None: return L10n.Alerts.Label.Fever.none
        }
    }
}

private extension CoughSeverity {
    func toLocalizedName() -> String {
        switch self {
        case .Dry: return L10n.Alerts.Label.Cough.dry
        case .Existing: return L10n.Alerts.Label.Cough.existing
        case .Wet: return L10n.Alerts.Label.Cough.wet
        case .None: return L10n.Alerts.Label.Cough.none
        }
    }
}

private extension Alert {

    // TODO localize
    func symptomList() -> [String] {
        let feverStr = "Fever: " + feverSeverity.toLocalizedName()
        let feverCoughStr = "Cough: " + coughSeverity.toLocalizedName()
        let breathlessnessStr = "Breathlessness: \(breathlessness)"

        // TODO map to "days ago"
        let earliestDate = "Earliest report date: \(earliestSymptomTime)"

        return [feverStr, feverCoughStr, breathlessnessStr, earliestDate]
    }

    func toViewData() -> AlertViewData {
        AlertViewData(
            symptoms: symptomList(),
            time: "\(contactTime)", // TODO map to date and format
            alert: self
        )
    }
}

private extension OperationState {

    func shouldShowText() -> Bool {
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
