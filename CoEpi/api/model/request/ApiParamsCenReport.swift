import Foundation

struct ApiParamsCenReport: Encodable {
    let reportID: String
    let report: String
    let cenKeys: String
    let reportTimestamp: Int64
}

extension ApiParamsCenReport {
    init(report: MyCenReport) {
        self.init(reportID: report.report.id, report: report.report.report.toBase64() ?? "Decoding error".toBase64()! , cenKeys: report.keys.joined(separator: ","),
                  reportTimestamp: report.report.timestamp)
    }
}
