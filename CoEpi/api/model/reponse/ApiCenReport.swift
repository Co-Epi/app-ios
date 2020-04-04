import Foundation

struct ApiCenReport: Codable {
    let reportID: String
    let report: String
    let reportTimeStamp: Int64
}

extension ApiCenReport {
    func toCenReport() -> CenReport {
        CenReport(id: reportID, report: report, timestamp: reportTimeStamp)
    }
}
