import CryptoKit
import Foundation
import RealmSwift
import Security
import RxSwift

protocol CENKeyDao {
    func generateAndStoreCENKey() -> Result<CENKey, DaoError>
    func insert(key: CENKey) -> Bool
    func getCENKeys(limit: Int64) -> [CENKey]

    // For debug view
    var generatedMyKey: ReplaySubject<String> { get }
}

class RealmCENKeyDao: RealmDao, CENKeyDao {
    private let cenLogic: CenLogic

    let realmProvider: RealmProvider

    let generatedMyKey: ReplaySubject<String> = .create(bufferSize: 1)

    init(realmProvider: RealmProvider, cenLogic: CenLogic) {
        self.realmProvider = realmProvider
        self.cenLogic = cenLogic
    }
 
    func generateAndStoreCENKey() -> Result<CENKey, DaoError> {
        let curTimestamp = Date().coEpiTimestamp

        let result: Result<CENKey, DaoError> = {
            if let latestCenKey = getLatestCENKey() {
                if (cenLogic.shouldGenerateNewCenKey(curTimestamp: curTimestamp, cenKeyTimestamp: latestCenKey.timestamp)) {
                    return generateAndInsertCenKey(curTimestamp: curTimestamp)

                } else {
                    return .success(latestCenKey)
                }
            } else { // There's no latest CEN key
                return generateAndInsertCenKey(curTimestamp: curTimestamp)
            }
        }()

        // Debugging
        switch result {
        case .success(let key): generatedMyKey.onNext(key.cenKey)
        case .failure(_): break
        }

        return result
    }


    private func generateAndInsertCenKey(curTimestamp: Int64) -> Result<CENKey, DaoError> {
        switch cenLogic.generateCenKey(curTimestamp: curTimestamp) {
        case .success(let key):
            _ = insert(key: key)
            return .success(key)
        case .failure(let error):
            switch error {
            case .couldNotComputeKey: return .failure(.couldNotComputeKey)
            }
        }
    }

    // TODO last n keys? for the reports?
    private func getLatestCENKey() -> CENKey? {
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
