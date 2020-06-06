import Foundation
import RealmSwift

class RealmCEN: Object {
    @objc dynamic var CEN = ""
    @objc dynamic var timestamp: Int64 = UnixTime.now().value

    convenience init(_ cen: CEN) {
        self.init()

        self.CEN = cen.CEN
        self.timestamp = cen.timestamp.value
    }

    override static func primaryKey() -> String? { "CEN" }
}
