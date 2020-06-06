import Foundation
import RealmSwift

protocol CENDao {
    func insert(cen: CEN) -> Bool
    func loadAllCENRecords() -> [CEN]?
    func match(start: UnixTime, end: UnixTime, hexEncodedCENs: [String]) -> [CEN]
    func loadCensForTimeInterval(start: UnixTime, end: UnixTime) -> [CEN]
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

    func match(start: UnixTime, end: UnixTime, hexEncodedCENs: [String]) -> [CEN] {
        realm.objects(RealmCEN.self)
            .filter("timestamp >= %d", start.value)
            .filter("timestamp <= %d", end.value)
            .filter(NSPredicate(format: "CEN IN %@", hexEncodedCENs))
            .map { CEN(CEN: $0.CEN, timestamp: UnixTime(value: $0.timestamp)) }
    }

    func loadAllCENRecords() -> [CEN]? {
        let DBCENObject = realm.objects(RealmCEN.self).sorted(byKeyPath: "timestamp", ascending: false)
        return DBCENObject.map { CEN(CEN: $0.CEN, timestamp: UnixTime(value: $0.timestamp)) }
    }
    
    func loadCensForTimeInterval(start: UnixTime, end: UnixTime) -> [CEN] {
        realm.objects(RealmCEN.self)
            .filter("timestamp >= %d", start.value)
            .filter("timestamp <= %d", end.value)
            .compactMap { CEN(CEN: $0.CEN, timestamp: UnixTime(value: $0.timestamp))
        }
    }
}
