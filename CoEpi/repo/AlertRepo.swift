import Foundation
import RxCocoa
import RxSwift

protocol AlertRepo {
    var alerts: Observable<[Alert]> { get }
    var updateReportsState: Observable<OperationState<CenReportUpdateResult>> { get }

    func removeAlert(alert: Alert)
    func updateReports()
}

class AlertRepoImpl: AlertRepo {
    private let cenReportsRepo: CENReportRepo
    private let coEpiRepo: CoEpiRepo

    lazy var updateReportsState: Observable<OperationState<CenReportUpdateResult>> = coEpiRepo.updateReportsState

    lazy private(set) var alerts: Observable<[Alert]> = cenReportsRepo.reports
        .map { reports in reports.map { $0.toAlert() }}

    init(cenReportsRepo: CENReportRepo, coEpiRepo: CoEpiRepo) {
        self.cenReportsRepo = cenReportsRepo
        self.coEpiRepo = coEpiRepo
    }

    func removeAlert(alert: Alert) {
        cenReportsRepo.delete(report: alert.report)
    }

    func updateReports() {
        coEpiRepo.updateReports()
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
