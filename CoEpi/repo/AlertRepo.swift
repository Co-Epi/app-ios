import Foundation
import RxCocoa
import RxSwift

protocol AlertRepo {
    var alertState: Observable<OperationState<[Alert]>> { get }

    func removeAlert(alert: Alert) -> Result<(), ServicesError>
    func linkedAlerts(alert: Alert) -> Result<[Alert], ServicesError>
    func updateIsRead(alert: Alert, isRead: Bool) -> Result<(), ServicesError>

    func updateReports()
}

class AlertRepoImpl: AlertRepo {

    private let alertsApi: AlertsApi
    private let notificationShower: NotificationShower

    private let alertsStateSubject: BehaviorRelay<OperationState<[Alert]>> =
        BehaviorRelay(value: .notStarted)
    lazy var alertState: Observable<OperationState<[Alert]>> = alertsStateSubject
        .asObservable()

    init(alertsApi: AlertsApi, notificationShower: NotificationShower) {
        self.alertsApi = alertsApi
        self.notificationShower = notificationShower
    }

    func removeAlert(alert: Alert) -> Result<(), ServicesError> {
        let result = alertsApi.deleteAlert(id: alert.id)
        switch result {
        case .success:
            // Note that alternatively we could return from Rust the updated alerts (from the local database)
            // but we're animating and we probably would have to perform this in the background
            removeAlertLocally(alert: alert)
        case .failure: break
        }
        return result
    }

    func linkedAlerts(alert: Alert) -> Result<[Alert], ServicesError> {
        let alertsState = alertsStateSubject.value
        switch alertsState {
        case .success(let alerts):
            let linkedAlerts = alerts
                .filter { $0.reportId == alert.reportId && $0.id != alert.id }
                .sorted { (alert1, alert2) -> Bool in
                    alert1.start.value > alert2.start.value
                }
            return .success(linkedAlerts)
        default: return .failure(.error(message: "No alerts to filter"))
        }
    }

    func updateIsRead(alert: Alert, isRead: Bool) -> Result<(), ServicesError> {
        let result = alertsApi.updateIsRead(id: alert.id, isRead: isRead)
        switch result {
        case .success: updateIsReadLocally(alert: alert)
        case .failure: break
        }
        return result
    }

    private func removeAlertLocally(alert: Alert) {
        let alertsState = alertsStateSubject.value
        switch alertsState {
        case .success(let alerts):
            let newAlerts = alerts.deleteFirst(element: alert)
            alertsStateSubject.accept(.success(data: newAlerts))
        default: break
        }
    }

    private func updateIsReadLocally(alert: Alert) {
        let alertsState = alertsStateSubject.value
        switch alertsState {
        case .success(let alerts):
            var updatedAlert = alert
            updatedAlert.isRead = true
            let newAlerts = alerts.replace(alert, with: updatedAlert)
            alertsStateSubject.accept(.success(data: newAlerts))
        default: break
        }
    }

    func updateReports() {
        if alertsStateSubject.value.isProgress() { return }
        alertsStateSubject.accept(.progress)

        switch alertsApi.fetchNewAlerts() {
        case .success(let alerts):
            log.w("Received new alerts in app: \(alerts)", tags: .ui)
            alertsStateSubject.accept(.success(data: alerts))
            if !alerts.isEmpty {
                notificationShower.showNotification(data: NotificationData(
                    id: .alerts,
                    title: L10n.Alerts.Notification.New.title,
                    body: L10n.Alerts.Notification.New.body
                ))
            }

        case .failure(let error):
            log.e("Error fetching alerts: \(error)")
            alertsStateSubject.accept(OperationState.failure(error: error))
        }
    }
}
