import Foundation

struct CEN: Codable {
    let CEN: String // Hex encoded
    let timestamp: Int64

    init(CEN: String, timestamp: Int64 = Date().coEpiTimestamp) {
        self.CEN = CEN
        self.timestamp = timestamp
    }
}
