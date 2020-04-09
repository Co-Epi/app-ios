import Foundation

struct CEN: Codable, CustomStringConvertible {
    let CEN: String // Hex encoded
    let timestamp: Int64

    init(CEN: String, timestamp: Int64 = Date().coEpiTimestamp) {
        self.CEN = CEN
        self.timestamp = timestamp
    }

    var description: String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return "CEN: \(CEN), time: \(date)"
    }
}
