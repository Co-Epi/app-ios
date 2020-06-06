import Foundation
import RealmSwift

/// Convenience
protocol RealmDao {
    var realmProvider: RealmProvider { get }

    var realm: Realm { get }

    func write(f: () -> Void)
}

extension RealmDao {

    var realm: Realm {
        realmProvider.realm
    }

    func write(f: () -> Void) {
        // TODO handle error, Result/exception
        try! realm.write {
            f()
        }
    }
}
