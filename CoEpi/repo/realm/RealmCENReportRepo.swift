import Foundation
import RealmSwift

class RealmCENReportRepo: CENReportRepo, RealmRepo {

    let realm: Realm

    init(realmProvider: RealmProvider) {
        realm = realmProvider.realm
    }

    func insert(report: CENReport) -> Bool {
        let realmCENReportObject = realm.objects(RealmCENReport.self).filter("CENReportID = %@", report.id)
        if realmCENReportObject.count == 0 {
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
}
