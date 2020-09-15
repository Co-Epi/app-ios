import Foundation
import RxSwift

protocol KeyValueStore {
    func putBool(key: KVKey, value: Bool)
    func getBool(key: KVKey) -> Bool
    func putString(key: KVKey, value: String)
    func getString(key: KVKey) -> String
}

enum KVKey: String {
    case seenOnboarding
    case filterAlertsWithSymptoms
    case filterAlertsWithLongDuration
    case filterAlertsWithShortDistance
    case reminderNotificationsEnabled
    case reminderHours
    case reminderMinutes
}

class KeyValueStoreImpl: KeyValueStore {
    func putBool(key: KVKey, value: Bool) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    func getBool(key: KVKey) -> Bool {
        UserDefaults.standard.bool(forKey: key.rawValue)
    }

    func putString(key: KVKey, value: String) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    func getString(key: KVKey) -> String {
        if let str = UserDefaults.standard.string(forKey: key.rawValue) {
            return str
        } else {
            return ""
        }
    }
}
