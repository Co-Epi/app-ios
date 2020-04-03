import CryptoKit
import Foundation
import RealmSwift
import Security

protocol CENKeyDao {
    func generateAndStoreCENKey() -> CENKey
    func insert(key: CENKey) -> Bool
    func getCENKeys(limit: Int64) -> [CENKey]
    func getLatestCENKey() -> CENKey?
}

class RealmCENKeyDao: RealmDao, CENKeyDao {
    private let cenLogic: CenLogic

    let realmProvider: RealmProvider

    init(realmProvider: RealmProvider, cenLogic: CenLogic) {
        self.realmProvider = realmProvider
        self.cenLogic = cenLogic
    }

    func generateAndStoreCENKey() -> CENKey {
        let curTimestamp = Date().coEpiTimestamp

        if let latestCenKey = getLatestCENKey() {
            if (cenLogic.shouldGenerateNewCenKey(curTimestamp: curTimestamp, cenKeyTimestamp: latestCenKey.timestamp)) {
                return generateAndInsertCenKey(curTimestamp: curTimestamp)

            } else {
                return latestCenKey
            }
        } else { // There's no latest CEN key
            return generateAndInsertCenKey(curTimestamp: curTimestamp)
        }
    }

    private func generateAndInsertCenKey(curTimestamp: Int64) -> CENKey {
        let newCENKey = cenLogic.generateCenKey(curTimestamp: curTimestamp)
        _ = insert(key: newCENKey)
        return newCENKey
    }

    // TODO last n keys? for the reports
    func getLatestCENKey() -> CENKey? {
        let cenKeysObject = realm.objects(RealmCENKey.self).sorted(byKeyPath: "timestamp", ascending: false)
        if let lastCenKey = cenKeysObject.first {
            return CENKey(cenKey: lastCenKey.CENKey, timestamp: lastCenKey.timestamp)
        } else {
            return nil
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
