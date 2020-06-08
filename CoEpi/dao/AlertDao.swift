import Foundation
import RealmSwift
import RxSwift

protocol AlertDao {
    var alerts: Observable<[Alert]> { get }

    func all() -> [Alert]?
    func insert(alert: Alert) -> Bool
    func delete(alert: Alert)
}

class RealmAlertDao: AlertDao, RealmDao {
    lazy var alerts = alertsSubject.asObservable()
    private let alertsSubject: BehaviorSubject<[Alert]> = BehaviorSubject(value: [])

    let realmProvider: RealmProvider

    var notificationToken: NotificationToken? = nil

    private let alertsResults: Results<RealmAlert>

    init(realmProvider: RealmProvider) {
        self.realmProvider = realmProvider

        alertsResults = realmProvider.realm.objects(RealmAlert.self)
            .filter("deleted = %@", NSNumber(value: false))

        notificationToken = alertsResults.observe { [weak self] (_: RealmCollectionChange) in
            guard let self = self else { return }
            self.alertsSubject.onNext(self.alertsResults.map {
                $0.toAlert()
            })
        }
    }

    func all() -> [Alert]? {
        let realmAlerts = realm.objects(RealmAlert.self).sorted(byKeyPath: "contactTime", ascending: true)
        return realmAlerts.map { $0.toAlert() }
    }

    func insert(alert: Alert) -> Bool {
        let dbAlerts = realm.objects(RealmAlert.self).filter("id = %@", alert.id)
        if dbAlerts.count == 0 {
            let newCEN = RealmAlert(alert)
            write {
                realm.add(newCEN)
            }
            return true
        } else {
            return false
        }
    }

    func delete(alert: Alert) {
        log.d("ACKing alert: \(alert)")

        guard let realmAlert = findAlertBy(id: alert.id) else {
            log.e("Couldn't find alert to delete: \(alert)")
            return
        }

        write {
            realmAlert.deleted = true
        }
    }

    private func findAlertBy(id: String) -> RealmAlert? {
        let results = realm.objects(RealmAlert.self).filter("id = %@", id)

        if (results.count > 1) {
            // Searching by id which is primary key, so can't have multiple results.
            fatalError("Multiple results for alert id: \(id)")
        } else {
            return results.first
        }
    }
}
