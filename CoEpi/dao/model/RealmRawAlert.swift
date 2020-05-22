import Foundation
import RealmSwift

final class RealmRawAlert : Object {
    @objc dynamic var id: String = ""
    @objc dynamic var memoStr: String = ""
    @objc dynamic var contactTime: Int64 = 0
    @objc dynamic var deleted: Bool = false

    override static func primaryKey() -> String? { "id" }

    convenience init(_ alert: RawAlert) {
        self.init()

        self.id = alert.id
        self.memoStr = alert.memoStr
        self.contactTime = alert.contactTime.value
        self.deleted = false
    }
}
