import Foundation
import RealmSwift

protocol CENDao {
    func insert(cen: CEN) -> Bool
    func loadAllCENRecords() -> [CEN]?
    func match(start: Int64, end: Int64, hexEncodedCENs: [String]) -> [CEN]
}

class RealmCENDao: CENDao, RealmDao {
    let realm: Realm
    // TODO better method to provide thread safe realm - maybe just put RealmProvider in trait
    private let realmProvider: RealmProvider

    init(realmProvider: RealmProvider) {
        realm = realmProvider.realm
        self.realmProvider = realmProvider
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

    func match(start: Int64, end: Int64, hexEncodedCENs: [String]) -> [CEN] {
        realmProvider.realm.objects(RealmCEN.self)
            .filter("timestamp >= %d", start)
            .filter("timestamp <= %d", end)
            .filter(NSPredicate(format: "CEN IN %@", hexEncodedCENs))
            .map { CEN(CEN: $0.CEN, timestamp: $0.timestamp) }
    }

    func loadAllCENRecords() -> [CEN]? {
        let DBCENObject = realm.objects(RealmCEN.self).sorted(byKeyPath: "timestamp", ascending: false)
        return DBCENObject.map { CEN(CEN: $0.CEN, timestamp: $0.timestamp) }
    }
}
