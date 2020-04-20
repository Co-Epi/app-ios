import Foundation

struct CEN: Codable, CustomStringConvertible {
    let CEN: String // Hex encoded
    let timestamp: UnixTime

    init(CEN: String, timestamp: UnixTime = .now()) {
        self.CEN = CEN
        self.timestamp = timestamp
    }

    var description: String {
        return "CEN: \(CEN), timestamp: \(timestamp)"
    }
}

extension CEN: Equatable {
    static func == (lhs: CEN, rhs: CEN) -> Bool {
        lhs.CEN == rhs.CEN
    }
}
