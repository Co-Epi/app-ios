import Foundation
import RxSwift
import os.log

// NOTE: This is interace for possible Rust shared library
// Reports storage unclear, most likely shared lib forwards api call result, we cache in Realm
// For now the caching happens _in_ CoEpiRepo

protocol CoEpiRepo {
    // Infection reports fetched periodically from the API
    var reports: Observable<[CENReport]> { get }

    // Store CEN from other device
    func storeObservedCen(cen: CEN)

    // Send symptoms report
    func sendReport(report: CENReport) -> Completable
}

class CoEpiRepoImpl: CoEpiRepo {
    private let cenReportRepo: CENReportRepo
    private let cenRepo: CENRepo
    private let api: Api

    init(cenReportRepo: CENReportRepo, cenRepo: CENRepo, api: Api) {
        self.cenReportRepo = cenReportRepo
        self.cenRepo = cenRepo
        self.api = api
    }

    lazy var reports: Observable<[CENReport]> = cenReportRepo.reports

    func storeObservedCen(cen: CEN) {
        if !(cenRepo.insert(cen: cen)) {
            os_log("Observed CEN already in DB: %@", log: blePeripheralLog, type: .debug, "\(cen)")
        }
    }

    func sendReport(report: CENReport) -> Completable {
        api.postCenReport(cenReport: report)
    }
}
