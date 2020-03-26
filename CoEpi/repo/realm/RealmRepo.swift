import Foundation
import RealmSwift

/// Convenience
protocol RealmRepo {
    var realm: Realm { get }

    func write(f: () -> Void)
}

extension RealmRepo {
    func write(f: () -> Void) {
        // TODO handle error, Result/exception
        try! realm.write {
            f()
        }
    }
}
