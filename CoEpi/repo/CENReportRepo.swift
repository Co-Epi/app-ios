import RxSwift
import os.log

protocol CENReportRepo {
    var reports: Observable<[ReceivedCenReport]> { get }

    func insert(report: ReceivedCenReport) -> Bool
    func delete(report: ReceivedCenReport)
}

class CenReportRepoImpl: CENReportRepo {
    private let cenReportDao: CENReportDao
    private let coEpiRepo: CoEpiRepo

    lazy var reports = cenReportDao.reports

    private let disposeBag = DisposeBag()

    init(cenReportDao: CENReportDao, coEpiRepo: CoEpiRepo) {
        self.cenReportDao = cenReportDao
        self.coEpiRepo = coEpiRepo

        coEpiRepo.reports.subscribe(onNext: { reports in
            os_log("Inserting reports in db: %@", type: .debug, reports)
            for report in reports {
                _ = cenReportDao.insert(report: report)
            }
        }, onError: { error in
            os_log("Error: %@", type: .error, error.localizedDescription)
        }).disposed(by: disposeBag)
    }

    func insert(report: ReceivedCenReport) -> Bool {
        cenReportDao.insert(report: report)
    }

    func delete(report: ReceivedCenReport) {
        cenReportDao.delete(report: report)
    }
}
