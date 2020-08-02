import Foundation

import RxSwift

protocol ObservableAlertFilters {
    var filters: Observable<AlertFilters> { get }
}

class ObservableAlertFiltersImpl: ObservableAlertFilters {
    let filters: Observable<AlertFilters>

    init(kvStore: ObservableKeyValueStore, filterSettings: AlertFilterSettings) {
        filters = Observable.combineLatest(
            kvStore.filterAlertsWithSymptoms,
            kvStore.filterAlertsWithLongDuration,
            kvStore.filterAlertsWithShortDistance
        ).map { withSymptoms, withLongDuration, withShortDistance in
            AlertFilters(
                withSymptoms: withSymptoms,
                withLongDuration: withLongDuration,
                withShortDistance: withShortDistance,
                settings: filterSettings
            )
        }
    }
}

struct AlertFilterSettings {
    let durationSecondsLargerThan: Int
    let distanceShorterThan: Measurement<UnitLength>
}

struct AlertFilters {
    let withSymptoms: Bool
    let withLongDuration: Bool
    let withShortDistance: Bool
    let settings: AlertFilterSettings
}

extension AlertFilters {
    func apply(to alerts: [Alert]) -> [Alert] {
        alerts.filter { alert -> Bool in
            apply(
                filter: withSymptoms,
                meetsCondition: { !alert.noSymptoms }) &&
            apply(
                filter: withLongDuration,
                meetsCondition: {
                    alert.durationSeconds > settings.durationSecondsLargerThan
                }) &&
            apply(
                filter: withShortDistance,
                meetsCondition: {
                    alert.avgDistance.converted(to: .feet).value <
                        Double(settings.distanceShorterThan.converted(to: .feet).value) })
        }
    }

    private func apply(filter: Bool, meetsCondition: () -> Bool) -> Bool {
        if filter {
            return meetsCondition()
        } else {
            return true
        }
    }
}
