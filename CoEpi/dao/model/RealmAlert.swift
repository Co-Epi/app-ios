import Foundation
import RealmSwift

final class RealmAlert: Object {
    @objc dynamic var id: String = ""

    @objc dynamic var start: Int64 = 0
    @objc dynamic var end: Int64 = 0
    @objc dynamic var minDistance: Float = 0
    @objc dynamic var avgDistance: Float = 0

    @objc dynamic var reportTime: Int64 = 0
    let earliestSymptomTime: RealmOptional<Int64> = RealmOptional()

    @objc dynamic var feverSeverity: String = ""
    @objc dynamic var coughSeverity: String = ""
    @objc dynamic var breathlessness: Bool = false
    @objc dynamic var muscleAches: Bool = false
    @objc dynamic var lossSmellOrTaste: Bool = false
    @objc dynamic var diarrhea: Bool = false
    @objc dynamic var runnyNose: Bool = false
    @objc dynamic var other: Bool = false
    @objc dynamic var noSymptoms: Bool = false

    @objc dynamic var deleted: Bool = false

    override static func primaryKey() -> String? { "id" }

    convenience init(_ alert: Alert) {
        self.init()

        self.id = alert.id

        self.start = alert.start.value
        self.end = alert.end.value
        self.minDistance = Float(alert.minDistance.converted(to: .meters).value)
        self.avgDistance = Float(alert.avgDistance.converted(to: .meters).value)

        self.reportTime = alert.reportTime.value
        if let time = alert.earliestSymptomTime.toOptional() {
            self.earliestSymptomTime.value = time.value
        }

        self.feverSeverity = alert.feverSeverity.rawValue
        self.coughSeverity = alert.coughSeverity.rawValue
        self.breathlessness = alert.breathlessness
        self.muscleAches = alert.muscleAches
        self.lossSmellOrTaste = alert.lossSmellOrTaste
        self.diarrhea = alert.diarrhea
        self.runnyNose = alert.runnyNose
        self.other = alert.other
        self.noSymptoms = alert.noSymptoms

        self.deleted = false
    }

    func toAlert() -> Alert {
        Alert(
            id: id,

            start: UnixTime(value: start),
            end: UnixTime(value: end),
            minDistance: Measurement(value: Double(minDistance), unit: .meters),
            avgDistance: Measurement(value: Double(avgDistance), unit: .meters),

            reportTime: UnixTime(value: reportTime),
            earliestSymptomTime: earliestSymptomTime.value.map {
                UserInput.some(UnixTime(value: $0)) } ?? UserInput.none,

            feverSeverity: FeverSeverity(rawValue: feverSeverity)!,
            coughSeverity: CoughSeverity(rawValue: coughSeverity)!,
            breathlessness: breathlessness,
            muscleAches: muscleAches,
            lossSmellOrTaste: lossSmellOrTaste,
            diarrhea: diarrhea,
            runnyNose: runnyNose,
            other: other,
            noSymptoms: noSymptoms
        )
    }
}
