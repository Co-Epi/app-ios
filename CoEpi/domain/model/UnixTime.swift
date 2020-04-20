import Foundation

struct UnixTime: Codable {
    let value: Int64

    static func minTimestamp() -> UnixTime {
        UnixTime(value: 0)
    }

    static func now() -> UnixTime {
        UnixTime(value: Int64(Date().timeIntervalSince1970))
    }
}

extension UnixTime: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(value), \(Date(timeIntervalSince1970: Double(value)))"
    }
}
