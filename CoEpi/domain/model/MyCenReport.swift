/// Report the user sends to the API
struct MyCenReport: Codable, CustomStringConvertible {
    let report: CenReport
    let keys: String

    var description: String {
        "MyCENReport report: \(report), keys: \(keys)"
    }
}
