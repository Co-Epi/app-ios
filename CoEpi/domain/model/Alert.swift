struct Alert {
    let id: String
    let exposure: String
    let timestamp: UnixTime
    let report: ReceivedCenReport
}

extension Alert: Equatable {
    static func == (lhs: Alert, rhs: Alert) -> Bool {
        lhs.id == rhs.id && lhs.exposure == rhs.exposure && lhs.report == rhs.report
    }
}
