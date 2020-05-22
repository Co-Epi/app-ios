struct RawAlert: Codable, CustomStringConvertible {
    let id: String
    let memoStr: String // Base64
    let contactTime: UnixTime

    var description: String {
        "RawAlert id: \(id), memoStr: \(memoStr), contactTime: \(contactTime)"
    }
}
