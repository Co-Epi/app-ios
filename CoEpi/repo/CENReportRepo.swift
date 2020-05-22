import RxSwift
import os.log

protocol CENReportRepo {
    var reports: Observable<[ReceivedCenReport]> { get }

    func sendReport(report: CenReport) -> Completable

    func insert(report: ReceivedCenReport) -> Bool
    func delete(report: ReceivedCenReport)
}

class CenReportRepoImpl: CENReportRepo {
    private let cenReportDao: CENReportDao

    lazy var reports = cenReportDao.reports

    init(cenReportDao: CENReportDao) {
        self.cenReportDao = cenReportDao
    }

    func sendReport(report: CenReport) -> Completable {
        Completable.create { _ in
            fatalError("TODO: Implement send report in Rust")
        }
    }

    func insert(report: ReceivedCenReport) -> Bool {
        cenReportDao.insert(report: report)
    }

    func delete(report: ReceivedCenReport) {
        cenReportDao.delete(report: report)
    }
}
