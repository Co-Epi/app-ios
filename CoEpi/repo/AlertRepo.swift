import RxCocoa
import RxSwift

protocol AlertRepo {
    var alerts: BehaviorRelay<[Alert]> { get }

    func removeAlert(alert: Alert)
}

class AlertRepoImpl: AlertRepo {
    private(set) var alerts: BehaviorRelay<[Alert]>
    
    private let tempAlertData: [Alert] = [
        Alert(id: "a", exposure: "testa"),
        Alert(id: "b", exposure: "testb"),
        Alert(id: "c", exposure: "testc"),
        Alert(id: "d", exposure: "testd"),
    ]

    init() {
        alerts = BehaviorRelay(value: tempAlertData)
    }

    func removeAlert(alert: Alert) {
        guard let idx = alerts.value.firstIndex(where: { $0.id == alert.id }) else { return }
        var newAlerts = alerts.value
        newAlerts.remove(at: idx)
        alerts.accept(newAlerts)
    }
}
