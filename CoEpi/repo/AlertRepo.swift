import Foundation
import RxCocoa
import RxSwift

protocol AlertRepo {
    var alerts: Observable<[Alert]> { get }
    var updateReportsState: Observable<VoidOperationState> { get }

    func removeAlert(alert: Alert)
    func updateReports()
}

class AlertRepoImpl: AlertRepo {
    private let alertsFetcher: AlertsFetcher
    private let alertDao: AlertDao
    private let notificationShower: NotificationShower

    private let updateReportsStateSubject: BehaviorRelay<VoidOperationState> = BehaviorRelay(value:
        .notStarted)
    lazy var updateReportsState: Observable<VoidOperationState> = updateReportsStateSubject
        .asObservable()

    lazy private(set) var alerts: Observable<[Alert]> = alertDao.alerts

    init(alertsFetcher: AlertsFetcher, alertDao: AlertDao, notificationShower: NotificationShower) {
        self.alertsFetcher = alertsFetcher
        self.alertDao = alertDao
        self.notificationShower = notificationShower
    }

    func removeAlert(alert: Alert) {
        alertDao.delete(alert: alert)
    }

    // TODO review thread safety with FFI/Rust: What happens if background task and foreground update
    // TODO (e.g. pull to refresh) enter at the same time? Do we need to enqueue/lock?
    func updateReports() {
        if updateReportsStateSubject.value.isProgress() {
            return
        }
        updateReportsStateSubject.accept(.progress)

        switch alertsFetcher.fetchNewAlerts() {
        case .success(let alerts):
            onFetchedReportsSuccess(alerts: alerts)
        case .failure(let error):
            log.e("Error fetching alerts: \(error)")
            updateReportsStateSubject.accept(OperationState.failure(error: error))
        }

        updateReportsStateSubject.accept(.notStarted)
    }

    private func onFetchedReportsSuccess(alerts: [Alert]) {
        // TODO improve error handling. If inserting alerts fails, these alerts can disappear
        // TODO as core may fetch only newer time segments.
        // TODO solution: persist the alerts in Rust too, make the operation transactional.
        let insertedCount = storeAlerts(alerts: alerts)
        if insertedCount > 0 {
            notificationShower.showNotification(data: NotificationData(
                id: .alerts,
                title: "New Contact Alerts",
                body: "New contact alerts have been detected. Tap for details."
            ))
        }
        updateReportsStateSubject.accept(.success(data: ()))
    }

    private func storeAlerts(alerts: [Alert]) -> Int {
        let insertedCount: Int = alerts.map {
            self.alertDao.insert(alert: $0)
        }.filter { $0 }.count

        if (insertedCount >= 0) {
            log.d("Added \(insertedCount) new alerts")
        }

        return insertedCount
    }
}
