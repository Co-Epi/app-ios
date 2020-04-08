import Foundation

struct ApiParamsCenReport: Encodable {
    let report: String
    let cenKeys: [String]
}

extension ApiParamsCenReport {
    init(report: MyCenReport) {
        self.init(report: report.report.report, cenKeys: report.keys)
    }
}
