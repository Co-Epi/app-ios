import RealmSwift
import Foundation

final class RealmCENReport : Object {

    // CENReportID is a local internal attribute only
    @objc dynamic var id: String = ""

    // report is a JSON Object (could be ByteArray) representing a report keyed by 2-4 CENKeys
    // Different app designs will have different ideas about what will go inside this report, differentiated by reportMimeType and other metadata that can be added to this
    @objc dynamic var report: String = ""

    @objc dynamic var reportTimestamp: Int64 = 0

    override static func primaryKey() -> String? { "id" }

    convenience init(_ r: CENReport) {
        self.init()

        id = r.id
        report = r.report
        reportTimestamp = r.timestamp
    }
}
