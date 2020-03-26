import Foundation
import RealmSwift

protocol ContactRepo {
    func addContact(cen: Contact)

    func retrieveContacts() -> [Contact]
}
