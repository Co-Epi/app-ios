import Foundation

struct CenReport: Codable, CustomStringConvertible {
    let id: String
    let report: String
    let timestamp: Int64

    var description: String {
        "CenReport id: \(id), report: \(report), timestamp: \(timestamp)"
    }
}

