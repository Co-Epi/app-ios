import Foundation
import RealmSwift

final class RealmCENKey : Object {
    @objc dynamic var CENKey: String = ""
    @objc dynamic var timestamp: Int64 = Date().coEpiTimestamp
    
    override static func primaryKey() -> String? { "CENKey" }

    convenience init(_ key: CENKey) {
        self.init()

        self.CENKey = key.cenKey
        self.timestamp = key.timestamp
    }
}
