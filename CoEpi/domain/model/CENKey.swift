import Foundation

struct CENKey: Codable {
    let cenKey: String // Hex
    let timestamp: UnixTime
    
    init(cenKey: String, timestamp: UnixTime = .now()) {
        self.cenKey = cenKey
        self.timestamp = timestamp
    }
}
