import Foundation
import RealmSwift

protocol CENDao {
    func insert(cen: CEN) -> Bool
    func loadAllCENRecords() -> [CEN]?
    func match(start: Int64, end: Int64, hexEncodedCENs: [String]) -> [CEN]
    func loadCensForTimeInterval(start: Int64, end: Int64) -> [CEN]
}

class RealmCENDao: CENDao, RealmDao {
    let realmProvider: RealmProvider

    init(realmProvider: RealmProvider) {
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
        realm.objects(RealmCEN.self)
            .filter("timestamp >= %d", start)
            .filter("timestamp <= %d", end)
            .filter(NSPredicate(format: "CEN IN %@", hexEncodedCENs))
            .map { CEN(CEN: $0.CEN, timestamp: $0.timestamp) }
    }

    func loadAllCENRecords() -> [CEN]? {
        let DBCENObject = realm.objects(RealmCEN.self).sorted(byKeyPath: "timestamp", ascending: false)
        return DBCENObject.map { CEN(CEN: $0.CEN, timestamp: $0.timestamp) }
    }
    
    func loadCensForTimeInterval(start: Int64, end: Int64) -> [CEN] {
        realm.objects(RealmCEN.self)
            .filter("timestamp >= %d", start)
            .filter("timestamp <= %d", end)
            .compactMap { CEN(CEN: $0.CEN, timestamp: $0.timestamp)
        }
    }
}
