import Foundation
import RealmSwift

final class RealmAlert : Object {
    @objc dynamic var id: String = ""
    @objc dynamic var memoStr: String = ""
    @objc dynamic var contactTime: Int64 = 0
    @objc dynamic var reportTime: Int64 = 0
    let earliestSymptomTime: RealmOptional<Int64> = RealmOptional()
    @objc dynamic var feverSeverity: String = ""
    @objc dynamic var coughSeverity: String = ""
    @objc dynamic var breathlessness: Bool = false

    @objc dynamic var deleted: Bool = false

    override static func primaryKey() -> String? { "id" }

    convenience init(_ alert: Alert) {
        self.init()

        self.id = alert.id

        if let time = alert.earliestSymptomTime.toOptional() {
            self.earliestSymptomTime.value = time.value
        }
        self.feverSeverity = alert.feverSeverity.rawValue
        self.coughSeverity = alert.coughSeverity.rawValue
        self.breathlessness = alert.breathlessness

        self.contactTime = alert.contactTime.value
        self.reportTime = alert.reportTime.value
        self.deleted = false
    }

    func toAlert() -> Alert {
        Alert(
            id: id,
            contactTime: UnixTime(value: contactTime),
            reportTime: UnixTime(value: reportTime),
            earliestSymptomTime: earliestSymptomTime.value.map { UserInput.some(UnixTime(value: $0)) } ?? UserInput.none,
            feverSeverity: FeverSeverity(rawValue: feverSeverity)!,
            coughSeverity: CoughSeverity(rawValue: coughSeverity)!,
            breathlessness: breathlessness
        )
    }
}
