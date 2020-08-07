import Foundation
import RxCocoa
import RxSwift

protocol AlertRepo {
    var alertState: Observable<OperationState<[Alert]>> { get }
    var alerts: Observable<[Alert]> { get }

    func removeAlert(alert: Alert) -> Result<Void, ServicesError>
    func updateIsRead(alert: Alert, isRead: Bool) -> Result<Void, ServicesError>

    func updateReports()
}

class AlertRepoImpl: AlertRepo {
    private let alertsApi: AlertsApi
    private let notificationShower: NotificationShower

    private let alertsStateSubject: BehaviorRelay<OperationState<[Alert]>> =
        BehaviorRelay(value: .notStarted)

    private let removeAlertTrigger: PublishSubject<Alert> = PublishSubject()
    private let updateIsReadTrigger: PublishSubject<(alert: Alert, isRead: Bool)> =
        PublishSubject()

    let alertState: Observable<OperationState<[Alert]>>
    let alerts: Observable<[Alert]>

    private let disposeBag = DisposeBag()

    init(alertsApi: AlertsApi, notificationShower: NotificationShower,
         alertFilters: ObservableAlertFilters) {
        self.alertsApi = alertsApi
        self.notificationShower = notificationShower

        alertState = alertsStateSubject.asObservable()
        let alerts = alertState.compactMap { state -> [Alert]? in
            switch state {
            case let .success(data): return data
            default: return nil
            }
        }
        self.alerts = Observable.combineLatest(alerts, alertFilters.filters) { alerts, filters in
            filters.apply(to: alerts)
        }

        removeAlertTrigger.withLatestFrom(alerts, resultSelector: { alert, alerts in
            alerts.deleteFirst(element: alert)
        })
            .subscribe(onNext: { [weak self] updatedAlerts in
                self?.alertsStateSubject.accept(.success(data: updatedAlerts))
            })
            .disposed(by: disposeBag)

        updateIsReadTrigger.withLatestFrom(alerts, resultSelector: { tuple, alerts in
            var updatedAlert = tuple.alert
            updatedAlert.isRead = tuple.isRead
            return alerts.replace(tuple.alert, with: updatedAlert)
        })
            .subscribe(onNext: { [weak self] updatedAlerts in
                self?.alertsStateSubject.accept(.success(data: updatedAlerts))
            })
            .disposed(by: disposeBag)
    }

    func removeAlert(alert: Alert) -> Result<Void, ServicesError> {
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

    func updateIsRead(alert: Alert, isRead: Bool) -> Result<Void, ServicesError> {
        let result = alertsApi.updateIsRead(id: alert.id, isRead: isRead)
        switch result {
        case .success: updateIsReadLocally(alert: alert, isRead: isRead)
        case .failure: break
        }
        return result
    }

    private func removeAlertLocally(alert: Alert) {
        removeAlertTrigger.onNext(alert)
    }

    private func updateIsReadLocally(alert: Alert, isRead: Bool) {
        updateIsReadTrigger.onNext((alert: alert, isRead: isRead))
    }

    func updateReports() {
        if alertsStateSubject.value.isProgress() { return }
        alertsStateSubject.accept(.progress)

        switch alertsApi.fetchNewAlerts() {
        case let .success(alerts):
            alertsStateSubject.accept(.success(data: alerts))
            if !alerts.isEmpty {
                notificationShower.showNotification(data: NotificationData(
                    id: .alerts,
                    title: L10n.Alerts.Notification.New.title,
                    body: L10n.Alerts.Notification.New.body
                ))
            }

        case let .failure(error):
            log.e("Error fetching alerts: \(error)")
            alertsStateSubject.accept(OperationState.failure(error: error))
        }
    }
}
