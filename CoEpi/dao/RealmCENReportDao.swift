import Foundation
import RealmSwift
import RxSwift
import os.log

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
            os_log("Report didn't exist in db, inserting: %@", type: .debug, report.description)
            let newCENReport = RealmCENReport(report)
            write {
                realm.add(newCENReport)
            }
            return true
        } else {
            //duplicate entry: skipping
            os_log("Report already in db, id = %@", type: .debug, report.report.id)
            return false
        }
    }

    func delete(report: ReceivedCenReport) {
        let result = realm.objects(RealmCENReport.self).filter("id = %@", report.report.id)
        write {
            realm.delete(result)
        }
    }
}

private extension RealmCENReport {

    func toCENReport() -> ReceivedCenReport {
        ReceivedCenReport(report: CenReport(id: id, report: report, timestamp: reportTimestamp))
    }
}
