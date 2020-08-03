struct AlertViewData: Hashable, AutoEquatable {
    let symptoms: String
    let contactTime: String
    let showUnreadDot: Bool
    let showRepeatedInteraction: Bool
    let alert: Alert

    func hash(into hasher: inout Hasher) {
        hasher.combine(alert.id)
    }
}

enum AlertCellViewData {
    case header(text: String)
    case alert(viewData: AlertViewData)

    func asAlertViewData() -> AlertViewData? {
        switch self {
        case .header: return nil
        case let .alert(viewData): return viewData
        }
    }
}

struct AlertViewDataSection: Hashable {
    let header: String
    var alerts: [AlertViewData]

    func hash(into hasher: inout Hasher) {
        hasher.combine(header)
    }

    // Here we don't use AutoEquatable / compare the alerts,
    // because that causes a change in the alerts
    // to animate the whole section, which looks weird.
    static func == (lhs: AlertViewDataSection, rhs: AlertViewDataSection) -> Bool {
        lhs.header == rhs.header
    }
}
