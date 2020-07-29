import Foundation

struct AlertDetailsViewData {
    let title: String
    let contactStart: String
    let contactDuration: String
    let avgDistance: String
    let minDistance: String
    let reportTime: String
    let symptoms: String
    let alert: Alert
}

enum LinkedAlertViewDataConnectionImage {
    case top, body, bottom
}

extension LinkedAlertViewDataConnectionImage {

    static func from(alertIndex: Int, alertsCount: Int) -> LinkedAlertViewDataConnectionImage {
        switch alertIndex {
        case _ where alertIndex == 0: return .top
        case _ where alertIndex == alertsCount - 1: return .bottom
        default: return .body
        }
    }
}

struct LinkedAlertViewData {
    let date: String
    let contactStart: String
    let contactDuration: String
    let symptoms: String
    let alert: Alert
    let image: LinkedAlertViewDataConnectionImage
    let bottomLine: Bool
}
