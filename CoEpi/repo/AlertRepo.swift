import Foundation
import RxCocoa
import RxSwift
import os.log

protocol AlertRepo {
    var alerts: Observable<[Alert]> { get }
    var updateReportsState: Observable<VoidOperationState> { get }

    func removeAlert(alert: Alert)
    func updateReports()
}

class AlertRepoImpl: AlertRepo {
    private let cenReportDao: CENReportDao
    private let alertsFetcher: AlertsFetcher
    private let alertDao: RawAlertDao

    private let updateReportsStateSubject: BehaviorRelay<VoidOperationState> = BehaviorRelay(value: .notStarted)
    lazy var updateReportsState: Observable<VoidOperationState> = updateReportsStateSubject.asObservable()

    lazy private(set) var alerts: Observable<[Alert]> = cenReportDao.reports
        .map { reports in reports.map { $0.toAlert() }}

    init(cenReportDao: CENReportDao, alertsFetcher: AlertsFetcher, alertDao: RawAlertDao) {
        self.cenReportDao = cenReportDao
        self.alertsFetcher = alertsFetcher
        self.alertDao = alertDao
    }

    func removeAlert(alert: Alert) {
        cenReportDao.delete(report: alert.report)
    }

    // TODO review thread safety with FFI/Rust: What happens if background task and foreground update
    // TODO (e.g. pull to refresh) enter at the same time? Do we need to enqueue/lock?
    func updateReports() {
        if updateReportsStateSubject.value.isProgress() {
            return
        }
        updateReportsStateSubject.accept(.progress)

        switch alertsFetcher.fetchNewAlerts() {
        case .success(let rawAlerts):
            for alert in rawAlerts {
                // TODO improve error handling. If inserting alerts fails, these alerts are lost forever as
                // TODO core will only fetch newer time segments.
                // TODO so we have to update "last fetched time segment" only if alerts save was success
                // TODO NOTE that storage will likely be moved to Rust. Let's wait until this is cleared.
                if alertDao.insert(alert: alert) {
                    os_log("Inserted new alert: %{alert}@", log: servicesLog, type: .debug, "\(alert)")
                }
            }
            updateReportsStateSubject.accept(.success(data: ()))

        case .failure(let error):
            os_log("Error fetching alerts: %{public}@", log: servicesLog, type: .debug, "\(error)")
            updateReportsStateSubject.accept(OperationState.failure(error: error))
        }

        updateReportsStateSubject.accept(.notStarted)
    }
}

private extension ReceivedCenReport {

    func toAlert() -> Alert {
        Alert(
            id: report.id,
            exposure: report.report,
            timestamp: UnixTime(value: report.timestamp),
            report: self
        )
    }
}
