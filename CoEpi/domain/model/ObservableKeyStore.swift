import RxSwift

protocol ObservableKeyValueStore {
    var filterAlertsWithSymptoms: Observable<Bool> { get }
    var filterAlertsWithLongDuration: Observable<Bool> { get }
    var filterAlertsWithShortDistance: Observable<Bool> { get }
    var reminderNotificationsEnabled: Observable<Bool> {get}

    func setFilterAlertsWithSymptoms(value: Bool)
    func setFilterAlertsWithLongDuration(value: Bool)
    func setFilterAlertsWithShortDistance(value: Bool)
    func setReminderNotificationsEnabled(value: Bool)
    func setReminderHours(value: String)
    func setReminderMinutes(value: String)
    func getReminderHours() -> String
    func getReminderMinutes() -> String
    
}

class ObservableKeyValueStoreImpl: ObservableKeyValueStore {
    let filterAlertsWithSymptomsSubject: BehaviorSubject<Bool>
    let filterAlertsWithLongDurationSubject: BehaviorSubject<Bool>
    let filterAlertsWithShortDistanceSubject: BehaviorSubject<Bool>
    var reminderNotificationsEnabledSubject: BehaviorSubject<Bool>

    lazy var filterAlertsWithSymptoms: Observable<Bool> =
        filterAlertsWithSymptomsSubject.asObservable()
    lazy var filterAlertsWithLongDuration: Observable<Bool> =
        filterAlertsWithLongDurationSubject.asObservable()
    lazy var filterAlertsWithShortDistance: Observable<Bool> =
        filterAlertsWithShortDistanceSubject.asObservable()
    lazy var reminderNotificationsEnabled: Observable<Bool> =
        reminderNotificationsEnabledSubject.asObservable()

    private let keyValueStore: KeyValueStore

    init(keyValueStore: KeyValueStore) {
        self.keyValueStore = keyValueStore

        filterAlertsWithSymptomsSubject =
            BehaviorSubject(value: keyValueStore.getBool(key: .filterAlertsWithSymptoms))
        filterAlertsWithLongDurationSubject =
            BehaviorSubject(value: keyValueStore.getBool(key: .filterAlertsWithLongDuration))
        filterAlertsWithShortDistanceSubject =
            BehaviorSubject(value: keyValueStore.getBool(key: .filterAlertsWithShortDistance))
        reminderNotificationsEnabledSubject =
            BehaviorSubject(value: keyValueStore.getBool(key: .reminderNotificationsEnabled))
    }

    func setFilterAlertsWithSymptoms(value: Bool) {
        keyValueStore.putBool(key: .filterAlertsWithSymptoms, value: value)
        filterAlertsWithSymptomsSubject.onNext(value)
    }

    func setFilterAlertsWithLongDuration(value: Bool) {
        keyValueStore.putBool(key: .filterAlertsWithLongDuration, value: value)
        filterAlertsWithLongDurationSubject.onNext(value)
    }

    func setFilterAlertsWithShortDistance(value: Bool) {
        keyValueStore.putBool(key: .filterAlertsWithShortDistance, value: value)
        filterAlertsWithShortDistanceSubject.onNext(value)
    }
    
    func setReminderNotificationsEnabled(value: Bool) {
        keyValueStore.putBool(key: .reminderNotificationsEnabled, value: value)
        reminderNotificationsEnabledSubject.onNext(value)
    }
    
    func setReminderHours(value: String) {
        keyValueStore.putString(key: .reminderHours, value: value)
    }
    
    func getReminderHours() -> String {
        keyValueStore.getString(key: .reminderHours)
    }
    
    func setReminderMinutes(value: String) {
        keyValueStore.putString(key: .reminderMinutes, value: value)
    }
    
    func getReminderMinutes() -> String {
        keyValueStore.getString(key: .reminderMinutes)
    }
}
