import Foundation
import RealmSwift

class RealmProvider {

    init() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 2, // Increase when schema changes
            migrationBlock: { migration, oldSchemaVersion in }
        )
    }
    
    var realm: Realm {
        // TODO handle error
        try! Realm()
    }
}
