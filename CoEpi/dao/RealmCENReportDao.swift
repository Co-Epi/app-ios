import Foundation
import RealmSwift
import RxSwift

// TODO remove, move functionality to RawAlertDao
protocol CENReportDao {
    var reports: Observable<[ReceivedCenReport]> { get }

    func insert(report: ReceivedCenReport) -> Bool
    func delete(report: ReceivedCenReport)
}

class RealmCENReportDao: CENReportDao, RealmDao {
    lazy var reports = reportsSubject.asObservable()
    private let reportsSubject: BehaviorSubject<[ReceivedCenReport]> = BehaviorSubject(value: [])

    var notificationToken: NotificationToken? = nil

    private let reportsResults: Results<RealmCENReport>

    let realmProvider: RealmProvider

    init(realmProvider: RealmProvider) {
        self.realmProvider = realmProvider

        reportsResults = realmProvider.realm.objects(RealmCENReport.self)
            .filter("deleted = %@", NSNumber(value: false))

        notificationToken = reportsResults.observe { [weak self] (_: RealmCollectionChange) in
            guard let self = self else { return }
            self.reportsSubject.onNext(self.reportsResults.map {
                $0.toCENReport()
            })
        }
    }

    func insert(report: ReceivedCenReport) -> Bool {
        let result = realm.objects(RealmCENReport.self).filter("id = %@", report.report.id)
        if result.count == 0 {
            log.d("Report didn't exist in db, inserting: \(report.description)")
            let newCENReport = RealmCENReport(report)
            write {
                realm.add(newCENReport)
            }
            return true
        } else {
            //duplicate entry: skipping
            log.d("Report already in db, id = \(report.report.id)")
            return false
        }
    }

    func delete(report: ReceivedCenReport) {
        log.d("ACKing report: \(report)")

        guard let realmReport = findReportBy(id: report.report.id) else {
            log.e("Couldn't find report to delete: \(report)")
            return
        }

        write {
            realmReport.deleted = true
        }
    }

    private func findReportBy(id: String) -> RealmCENReport? {
        let results = realm.objects(RealmCENReport.self).filter("id = %@", id)

        if (results.count > 1) {
            // Searching by id which is primary key, so can't have multiple results.
            fatalError("Multiple results for report id: \(id)")
        } else {
            return results.first
        }
    }
}

private extension RealmCENReport {

    func toCENReport() -> ReceivedCenReport {
        ReceivedCenReport(report: CenReport(id: id, report: report, timestamp: reportTimestamp))
    }
}
