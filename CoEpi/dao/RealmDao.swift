import Foundation
import RealmSwift

/// Convenience
protocol RealmDao {
    var realm: Realm { get }

    func write(f: () -> Void)
}

extension RealmDao {
    func write(f: () -> Void) {
        // TODO handle error, Result/exception
        try! realm.write {
            f()
        }
    }
}
