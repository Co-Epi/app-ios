import Foundation

struct CENKey: Codable {
    let cenKey: String // Hex
    let timestamp: Int64
    
    init(cenKey: String, timestamp: Int64 = Date().coEpiTimestamp) {
        self.cenKey = cenKey
        self.timestamp = timestamp
    }
}
