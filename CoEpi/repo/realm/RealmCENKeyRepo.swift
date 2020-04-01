import CryptoKit
import Foundation
import RealmSwift
import Security

class RealmCENKeyRepo: CENKeyRepo, RealmRepo {
    var realm: Realm

    //static var cenKey: String = ""
    var cenKeyTimestamp: Int64 = 0

    init(realmProvider: RealmProvider) {
        realm = realmProvider.realm
    }

    func generateAndStoreCENKey() -> CENKey {
        func getLatestCENKey() -> CENKey? {
            let cenKeysObject = realm.objects(RealmCENKey.self).sorted(byKeyPath: "timestamp", ascending: false)
            if cenKeysObject.count == 0 {
                return nil
            } else {
                self.cenKeyTimestamp = cenKeysObject.first?.timestamp ?? Int64(Date().timeIntervalSince1970)
                return CENKey(cenKey: cenKeysObject[0].CENKey, timestamp: self.cenKeyTimestamp)
            }
        }

        //Retrieve last cenKey and cenKeyTimestamp from CENKey
        let latestCENKey = getLatestCENKey()
        let curTimestamp = Int64(Date().timeIntervalSince1970)
        if ( ( cenKeyTimestamp == 0 ) || ( roundedTimestamp(ts: curTimestamp) > roundedTimestamp(ts: cenKeyTimestamp) ) ) {
            //generate a new AES Key and store it in local storage

            //generate base64string representation of key
            let cenKeyString = computeSymmetricKey()
            let cenKeyTimestamp = curTimestamp

            //Create CENKey and insert/save to Realm
            let newCENKey = CENKey(cenKey: cenKeyString, timestamp: cenKeyTimestamp)
            _ = insert(key: newCENKey)
            return newCENKey
        } else {
            return latestCENKey!
        }
    }

    func computeSymmetricKey() -> String {
        var keyData = Data(count: 32) // 32 bytes === 256 bits
        let keyDataCount = keyData.count
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, keyDataCount, mutableBytes)
        }
        if result == errSecSuccess {
            return keyData.base64EncodedString()
        } else {
            return ""
        }
    }

    func getCENKeys(limit: Int64) -> [CENKey] {
        let cenKeysObject = realm.objects(RealmCENKey.self).sorted(byKeyPath: "timestamp", ascending: false)
        if cenKeysObject.count == 0 {
            return []
        } else {
            var retrievedCENKeyList:[CENKey] = []
            for index in 0..<cenKeysObject.count {
                retrievedCENKeyList.append(CENKey(cenKey: cenKeysObject[index].CENKey,
                                                  timestamp: cenKeysObject[index].timestamp))
                if retrievedCENKeyList.count >= limit {
                    break
                }
            }
            return retrievedCENKeyList
        }
    }

    func insert(key: CENKey) -> Bool {
        let sameObject = realm.objects(RealmCENKey.self).filter("timestamp = %@", key.timestamp)
        if sameObject.count > 0 {
            //Duplicate Entry: NOT inserting
            return false
        } else {
            let newCENKey = RealmCENKey(key)
            write {
                realm.add(newCENKey)
            }
            return true
        }
    }
}
