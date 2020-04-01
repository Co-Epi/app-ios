import Foundation

struct CENKey : Codable {
    let cenKey: String
    let timestamp: Int64
    
    init(cenKey: String, timestamp: Int64 = Int64(Date().timeIntervalSince1970)) {
        self.cenKey = cenKey
        self.timestamp = timestamp
    }
}
