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
        case 0: return .top
        case alertsCount - 1: return .bottom
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

extension AlertDetailsViewData {
    static func empty() -> AlertDetailsViewData {
        AlertDetailsViewData(
            title: "", contactStart: "", contactDuration: "", avgDistance: "",
            minDistance: "", reportTime: "", symptoms: "", alert:
                Alert(id: "", reportId: "",
                      start: UnixTime.minTimestamp(), end: UnixTime.minTimestamp(),
                      minDistance: Measurement(value: 0, unit: .meters),
                      avgDistance: Measurement(value: 0, unit: .meters),
                      reportTime: UnixTime.minTimestamp(), earliestSymptomTime: .none,
                      feverSeverity: .None, coughSeverity: .None, breathlessness: false,
                      muscleAches: false, lossSmellOrTaste: false, diarrhea: false,
                      runnyNose: false, other: false, noSymptoms: false, isRead: false))
    }
}
