import Foundation

protocol RawAlertDao {
    func all() -> [RawAlert]?
    func insert(alert: RawAlert) -> Bool
}

class RealmRawAlertDao: RawAlertDao, RealmDao {

    let realmProvider: RealmProvider

    init(realmProvider: RealmProvider) {
        self.realmProvider = realmProvider
    }

    func all() -> [RawAlert]? {
        let realmAlerts = realm.objects(RealmRawAlert.self).sorted(byKeyPath: "contactTime", ascending: true)
        return realmAlerts.map {
            RawAlert(id: $0.id, memoStr: $0.memoStr, contactTime: UnixTime(value: $0.contactTime))
        }
    }

    func insert(alert: RawAlert) -> Bool {
        let dbAlerts = realm.objects(RealmRawAlert.self).filter("id = %@", alert.id)
        if dbAlerts.count == 0 {
            let newCEN = RealmRawAlert(alert)
            write {
                realm.add(newCEN)
            }
            return true
        } else {
            return false
        }
    }
}
