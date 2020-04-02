import Foundation
import RealmSwift
import RxSwift

protocol CENReportDao {
    var reports: Observable<[CENReport]> { get }

    func insert(report: CENReport) -> Bool
    func delete(report: CENReport)
}

class RealmCENReportDao: CENReportDao, RealmDao {
    lazy var reports = reportsSubject.asObservable()
    private let reportsSubject: BehaviorSubject<[CENReport]> = BehaviorSubject(value: [])
    
    let realm: Realm

    var notificationToken: NotificationToken? = nil

    private let reportsResults: Results<RealmCENReport>

    init(realmProvider: RealmProvider) {
        realm = realmProvider.realm

        reportsResults = realm.objects(RealmCENReport.self)
        notificationToken = reportsResults.observe { [weak self] (_: RealmCollectionChange) in
            guard let self = self else { return }
            self.reportsSubject.onNext(self.reportsResults.map {
                $0.toCENReport()
            })
        }
    }

    func insert(report: CENReport) -> Bool {
        let result = realm.objects(RealmCENReport.self).filter("id = %@", report.id)
        if result.count == 0 {
            let newCENReport = RealmCENReport(report)
            write {
                realm.add(newCENReport)
            }
            return true
        } else {
            //duplicate entry: skipping
            return false
        }
    }

    func delete(report: CENReport) {
        let result = realm.objects(RealmCENReport.self).filter("id = %@", report.id)
        write {
            realm.delete(result)
        }
    }
}

private extension RealmCENReport {

    func toCENReport() -> CENReport {
        CENReport(id: id, report: report, timestamp: reportTimestamp)
    }
}
