import Foundation
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
            // TODO revert to reports. Temporarily only keys to test exposure.
//            Alert(id: "$0.id", exposure: $0.report, report: $0)
            Alert(id: "TODO",
                  exposure: $0.cenKey,
                  report: CENReport(id: "0", report: "TODO", timestamp: Int64(Date().timeIntervalSince1970)))
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
