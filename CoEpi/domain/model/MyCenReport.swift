/// Report the user sends to the API
struct MyCenReport: Codable, CustomStringConvertible {
    let id: String
    let report: CenReport
    let keys: [String]

    var description: String {
        "MyCENReport id: \(id), report: \(report), keys: \(keys)"
    }
}
