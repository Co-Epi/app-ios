import RxCocoa
import RxSwift

// TODO clarify logic alerts <-> CEN reports
protocol AlertRepo {
    var alerts: Observable<[Alert]> { get }

    func removeAlert(alert: Alert)
}

class AlertRepoImpl: AlertRepo {

    // For now like this. Later dependencies may be inverted to CENReportRepo -> CoEpiRepo, and we reference here only CoEpiRepo
    private let coEpiRepo: CoEpiRepo
    private let cenReportsRepo: CENReportRepo

    lazy private(set) var alerts: Observable<[Alert]> = coEpiRepo.reports.map { reports in
        reports.map {
            Alert(id: $0.id, exposure: $0.report, report: $0)
        }
    }

    init(coEpiRepo: CoEpiRepo, cenReportsRepo: CENReportRepo) {
        self.coEpiRepo = coEpiRepo
        self.cenReportsRepo = cenReportsRepo
    }

    func removeAlert(alert: Alert) {
        cenReportsRepo.delete(report: alert.report)
    }
}
