import Dip
import RxCocoa
import RxSwift
import os.log
import Foundation

class AlertsViewModel {
    private let alertRepo: AlertRepo

    let alertCells: Driver<[AlertViewDataSection]>
    let updateStatusText: Driver<String>

    init(alertRepo: AlertRepo) {
        self.alertRepo = alertRepo

        alertCells = alertRepo.alerts
            .map { alerts in alerts.toSections() }
            .observeOn(MainScheduler.instance)
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

private extension Array where Element == Alert {
    
    func toSections() -> [AlertViewDataSection] {
        let grouped: Dictionary<HeaderData, [Alert]> = Dictionary(grouping: self, by: { alert in
            HeaderData(
                text: alert.contactTime.toDate().formatMonthOrdinalDay(),
                time: alert.contactTime.value
            )
        })

        let sorted: [(HeaderData, [Alert])] = grouped.sorted { (data1, data2) -> Bool in
            data1.key.time > data2.key.time
        }

        return sorted.map { headerData, alerts in
            AlertViewDataSection(
                header: headerData.text,
                alerts: alerts.map { $0.toViewData() }
            )
        }
    }

    private struct HeaderData: Hashable {
        let text: String
        let time: Int64
    }
}

private extension FeverSeverity {
    func toSymptomUIString() -> String? {
        switch self {
        case .Mild: return L10n.Alerts.Label.Fever.mild
        case .Serious: return L10n.Alerts.Label.Fever.serious
        case .None: return nil
        }
    }
}

private extension CoughSeverity {
    func toSymptomUIString() -> String? {
        switch self {
        case .Dry: return L10n.Alerts.Label.Cough.dry
        case .Existing: return L10n.Alerts.Label.Cough.existing
        case .Wet: return L10n.Alerts.Label.Cough.wet
        case .None: return nil
        }
    }
}

private extension Alert {

    func symptomListString() -> String {
        [
            coughSeverity.toSymptomUIString(),
            breathlessnessUIString(),
            feverSeverity.toSymptomUIString()
        ].compactMap { $0 }.joined(separator: "\n")
    }

    func toViewData() -> AlertViewData {
        AlertViewData(
            symptoms: symptomListString(),
            contactTime: DateFormatters.dateHoursMins.string(from: contactTime.toDate()),
            alert: self
        )
    }

    private func breathlessnessUIString() -> String? {
        if (breathlessness) {
            return L10n.Alerts.Label.breathlessness
        } else {
            return nil
        }
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

private extension Date {

    // Special formatting to add "th" to the day.
    // TODO test with non-EN langs. Probably needs to differentiate based on locale.
    func formatMonthOrdinalDay() -> String {
        let day = Calendar.current.component(.day, from: self)
        let dayOrdinal = NumberFormatters.ordinal.string(from: NSNumber(value: day))!
        let month = DateFormatters.month.string(from: self)
        return "\(month) \(dayOrdinal)"
    }
}
