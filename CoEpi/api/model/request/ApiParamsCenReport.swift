import Foundation

struct ApiParamsCenReport: Encodable {
    let reportID: String
    let report: String
    let cenKeys: String
    let reportTimestamp: Int64
}

extension ApiParamsCenReport {
    init(report: MyCenReport) {
        self.init(reportID: report.id, report: report.report.report, cenKeys: report.keys,
                  reportTimestamp: report.report.timestamp)
    }
}
