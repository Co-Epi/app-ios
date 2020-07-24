import Foundation

struct ApiParamsCenReport: Encodable {
    let reportID: String
    let report: String
    let cenKeys: String
    let reportTimestamp: Int64
}

extension ApiParamsCenReport {
    init(report: MyCenReport) {
        //Utf-8 decoding can be force unwrapped, see https://stackoverflow.com/a/46152738/930450
        self.init(
            reportID: report.report.id,
            report: report.report.report.toBase64(),
            cenKeys: report.keys.joined(separator: ","),
            reportTimestamp: report.report.timestamp)
    }
}
