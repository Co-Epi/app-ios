import Foundation
import RealmSwift

class RealmContactRepo: ContactRepo, RealmRepo {
    let realm: Realm

    init(realmProvider: RealmProvider) {
        realm = realmProvider.realm
    }

    func addContact(cen: Contact) {
        write {
            realm.add(RealmContact(cen))
        }
    }

    // Most simple version
    // Ideally executed as part of flow in a background thread (e.g. fetch - grouping - send to api)
    // If critical for performance, the mapping to plain objects can be left out
    // NOTE Realm objects can't switch between threads. If it's necessary, use ThreadSafeReference.
    func contacts() -> [Contact] {
        return realm.objects(RealmContact.self).map {
            Contact(cen: $0.cen, date: $0.date)
        }
    }

//    // Retrieves contacts in background, maps to plain objects and returns them in main queue
//    func retrieveContacts(callback: ([Contact]) -> Void) {
//        DispatchQueue.global(qos: .background).async {
//            let realmContacts = self.realm.objects(RealmContact.self)
//            let contacts: [Contact] = realmContacts.map {
//                Contact(cen: $0.cen, date: $0.date)
//            }
//            DispatchQueue.main.async {
//                callback(contacts)
//            }
//        }
//    }
}
