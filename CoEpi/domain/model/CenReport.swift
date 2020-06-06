import Foundation

struct CenReport: Codable, CustomStringConvertible {
    let id: String
    let report: String
    let timestamp: Int64

    var description: String {
        "CenReport id: \(id), report: \(report), timestamp: \(timestamp)"
    }
}

extension CenReport: Equatable {
    static func == (lhs: CenReport, rhs: CenReport) -> Bool {
        lhs.id == rhs.id && lhs.report == rhs.report && lhs.timestamp == rhs.timestamp
    }
}
