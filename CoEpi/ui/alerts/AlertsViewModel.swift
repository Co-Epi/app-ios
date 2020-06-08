import Dip
import RxCocoa
import RxSwift
import Foundation

class AlertsViewModel {
    private let alertRepo: AlertRepo
    private let nav: RootNav

    let alertCells: Driver<[AlertViewDataSection]>
    let updateStatusText: Driver<String>

    init(alertRepo: AlertRepo, nav: RootNav) {
        self.alertRepo = alertRepo
        self.nav = nav

        alertCells = alertRepo.alerts
            .map { alerts in alerts.toSections() }
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: [])

        updateStatusText = alertRepo.updateReportsState
            .do(onNext: { result in
                log.d("Got alerts result in view model: \(result)")
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

    func onAlertTap(alert: AlertViewData) {
        nav.navigate(command: .to(destination: .alertDetails(alert: alert.alert)))
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
            contactTime: DateFormatters.hoursMins.string(from: contactTime.toDate()),
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
