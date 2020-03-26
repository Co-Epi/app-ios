import Foundation
import RealmSwift

class RealmContact: Object {
    @objc dynamic var cen = ""
    @objc dynamic var date = Date()

    convenience init(_ contact: Contact) {
        self.init()

        self.cen = contact.cen
        date = contact.date
    }
}
