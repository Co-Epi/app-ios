import RxSwift

protocol ObservableKeyValueStore {
    var filterAlertsWithSymptoms: Observable<Bool> { get }
    var filterAlertsWithLongDuration: Observable<Bool> { get }
    var filterAlertsWithShortDistance: Observable<Bool> { get }
    var reminderNotificationsEnabled: Observable<Bool> {get}

    func setFilterAlertsWithSymptoms(value: Bool)
    func setFilterAlertsWithLongDuration(value: Bool)
    func setFilterAlertsWithShortDistance(value: Bool)
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
}
