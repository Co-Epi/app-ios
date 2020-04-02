import RxSwift

protocol CENReportRepo {
    var reports: Observable<[CENReport]> { get }

    func insert(report: CENReport) -> Bool
    func delete(report: CENReport)
}

class CenReportRepoImpl: CENReportRepo {
    private let cenReportDao: CENReportDao

    lazy var reports = cenReportDao.reports

    init(cenReportDao: CENReportDao) {
        self.cenReportDao = cenReportDao
    }

    func insert(report: CENReport) -> Bool {
        cenReportDao.insert(report: report)
    }

    func delete(report: CENReport) {
        cenReportDao.delete(report: report)
    }
}
