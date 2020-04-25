struct ReceivedCenReport: Codable, CustomStringConvertible {
    let report: CenReport

    var description: String {
        "ReceivedCenReport: \(report)"
    }
}

extension ReceivedCenReport: Equatable {
    static func == (lhs: ReceivedCenReport, rhs: ReceivedCenReport) -> Bool {
        lhs.report == rhs.report
    }
}
