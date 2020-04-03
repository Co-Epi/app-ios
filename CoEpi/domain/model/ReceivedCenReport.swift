struct ReceivedCenReport: Codable, CustomStringConvertible {
    let report: CenReport

    var description: String {
        "ReceivedCenReport: \(report)"
    }
}
