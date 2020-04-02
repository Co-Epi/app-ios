import Foundation
import RealmSwift

protocol CENDao {
    func insert(cen: CEN) -> Bool
    func loadAllCENRecords() -> [CEN]?
}

class RealmCENDao: CENDao, RealmDao {

    let realm: Realm

    init(realmProvider: RealmProvider) {
        realm = realmProvider.realm
    }

    func insert(cen: CEN) -> Bool {
        let DBCENObject = realm.objects(RealmCEN.self).filter("CEN = %@", cen.CEN)
        if DBCENObject.count == 0 {
            let newCEN = RealmCEN(cen)
            write {
                realm.add(newCEN)
            }
            return true
        } else {
            //duplicate entry: skipping
            return false
        }
    }

    func loadAllCENRecords() -> [CEN]? {
        let DBCENObject = realm.objects(RealmCEN.self).sorted(byKeyPath: "timestamp", ascending: false)
        return DBCENObject.map { CEN(CEN: $0.CEN, timestamp: $0.timestamp) }
    }
}
