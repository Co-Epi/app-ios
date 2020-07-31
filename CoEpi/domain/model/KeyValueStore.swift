import Foundation
import RxSwift

protocol KeyValueStore {
    func putBool(key: KVKey, value: Bool)
    func getBool(key: KVKey) -> Bool
}

enum KVKey: String {
    case seenOnboarding
    case filterAlertsWithSymptoms
    case filterAlertsWithLongDuration
    case filterAlertsWithShortDistance
}

class KeyValueStoreImpl: KeyValueStore {
    func putBool(key: KVKey, value: Bool) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    func getBool(key: KVKey) -> Bool {
        UserDefaults.standard.bool(forKey: key.rawValue)
    }
}
