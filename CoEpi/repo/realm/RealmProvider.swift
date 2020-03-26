import Foundation
import RealmSwift

class RealmProvider {
    var realm: Realm {
        // TODO handle error
        try! Realm()
    }
}
