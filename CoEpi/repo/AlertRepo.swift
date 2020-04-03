import Foundation
import RxCocoa
import RxSwift

protocol AlertRepo {
    var alerts: Observable<[Alert]> { get }

    func removeAlert(alert: Alert)
}

class AlertRepoImpl: AlertRepo {
    private let cenReportsRepo: CENReportRepo

    lazy private(set) var alerts: Observable<[Alert]> = cenReportsRepo.reports.map { reports in
        reports.map {
            Alert(id: $0.report.id, exposure: $0.report.report, report: $0)
        }
    }

    init(cenReportsRepo: CENReportRepo) {
        self.cenReportsRepo = cenReportsRepo
    }

    func removeAlert(alert: Alert) {
        cenReportsRepo.delete(report: alert.report)
    }
}
