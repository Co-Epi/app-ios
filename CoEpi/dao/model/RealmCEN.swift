import Foundation
import RealmSwift

class RealmCEN: Object {
    @objc dynamic var CEN = ""
    @objc dynamic var timestamp: Int64 = Date().coEpiTimestamp

    convenience init(_ cen: CEN) {
        self.init()

        self.CEN = cen.CEN
        self.timestamp = cen.timestamp
    }

    override static func primaryKey() -> String? { "CEN" }
}
