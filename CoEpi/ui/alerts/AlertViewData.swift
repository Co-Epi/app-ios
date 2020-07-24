struct AlertViewData {
    let symptoms: String
    let contactTime: String
    let alert: Alert
}

enum AlertCellViewData {
    case header(text: String)
    case alert(viewData: AlertViewData)

    func asAlertViewData() -> AlertViewData? {
        switch self {
        case .header: return nil
        case .alert(let viewData): return viewData
        }
    }
}

struct AlertViewDataSection {
    let header: String
    let alerts: [AlertViewData]
}
