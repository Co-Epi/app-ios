import Dip
import Foundation
import RxCocoa
import RxSwift

class AlertsViewModel {
    private let alertRepo: AlertRepo
    private let nav: RootNav

    let alertCells: Driver<(sections: [AlertViewDataSection], animate: Bool)>
    let updateStatusText: Driver<String>

    private let selectAlertTrigger: PublishSubject<Alert> = PublishSubject()

    private let disposeBag = DisposeBag()

    init(alertRepo: AlertRepo, nav: RootNav) {
        self.alertRepo = alertRepo
        self.nav = nav

        alertCells = alertRepo.alerts
            .startWith([])
            .enumerated()
            .pairwise()
            .map { prev, curr in
                // Animate only deletion (or insert, but we don't use this)
                // i.e. not when loaded the first time or when updating read status
                (curr.element, curr.index > 1 && curr.element.count != prev.element.count)
            }
            .map { alerts, animate in
                (sections: alerts.toSections(allAlerts: alerts), animate: animate)
            }
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: (sections: [], animate: false))

        updateStatusText = alertRepo.alertState
            .do(onNext: { result in
                log.d("Got alerts result in view model: \(result)")
            })
            .filter { $0.shouldShowText() }
            .map { $0.asText() }
            .asDriver(onErrorJustReturn: "Unknown error")

        selectAlertTrigger.withLatestFrom(
            alertRepo.alerts,
            resultSelector: { alert, alerts in
                AlertDetailsViewModelParams(
                    alert: alert,
                    linkedAlerts: linkedAlerts(alert: alert, alerts: alerts)
                )
            }
        )
        .subscribe(onNext: { pars in
            nav.navigate(command: .to(destination: .alertDetails(pars: pars)))
        })
        .disposed(by: disposeBag)
    }

    func updateReports() {
        alertRepo.updateReports()
    }

    func acknowledge(alert: AlertViewData) {
        switch alertRepo.removeAlert(alert: alert.alert) {
        case .success: log.i("Alert: \(alert.alert.id) was removed.")
        case let .failure(e): log.e("Alert: \(alert.alert.id) couldn't be removed: \(e)")
        }
    }

    func onAlertTap(alert: AlertViewData) {
        switch alertRepo.updateIsRead(alert: alert.alert, isRead: true) {
        case .success: log.i("Alert: \(alert.alert.id) was marked as read.")
        case let .failure(e): log.e("Alert: \(alert.alert.id) couldn't be marked as read: \(e)")
        }
        selectAlertTrigger.onNext(alert.alert)
    }
}

private extension Array where Element == Alert {
    func toSections(allAlerts: [Alert]) -> [AlertViewDataSection] {
        return
            sorted { (alert1, alert2) -> Bool in
                alert1.start.value > alert2.start.value
            }.groupByOrdered {
                $0.start.toDate().formatMonthOrdinalDay()
            }.map { headerText, alerts in
                AlertViewDataSection(
                    header: headerText,
                    alerts: alerts.map {
                        $0.toViewData(allAlerts: allAlerts)
                    }
                )
            }
    }

    private struct HeaderData: Hashable {
        let text: String
        let time: Int64
    }
}

private extension Alert {
    func toViewData(allAlerts: [Alert]) -> AlertViewData {
        AlertViewData(
            symptoms: symptomUIStrings().joined(separator: ", ")
                .lowercased().capitalizingFirstLetter(),
            contactTime: DateFormatters.hoursMins.string(from: start.toDate()),
            showUnreadDot: !isRead,
            showRepeatedInteraction: hasLinkedAlerts(alert: self,
                                                     alerts: allAlerts),
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
        case let .failure(error): return "Error updating: \(error)"
        }
    }
}

private func hasLinkedAlerts(alert: Alert, alerts: [Alert]) -> Bool {
    alerts.contains { linkedAlertsPredicate(alert: alert)($0) }
}

private func linkedAlerts(alert: Alert, alerts: [Alert]) -> [Alert] {
    alerts
        .filter(linkedAlertsPredicate(alert: alert))
        .sorted { (alert1, alert2) -> Bool in
            alert1.start.value > alert2.start.value
        }
}

private func linkedAlertsPredicate(alert: Alert) -> (Alert) -> Bool {
    { $0.reportId == alert.reportId && $0.id != alert.id }
}
