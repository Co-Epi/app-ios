import Foundation

// TODO rename in exposure
struct Alert: AutoEquatable {
    let id: String
    let reportId: String
    
    let start: UnixTime
    let end: UnixTime
    let minDistance: Measurement<UnitLength>
    let avgDistance: Measurement<UnitLength>
    let reportTime: UnixTime

    let earliestSymptomTime: UserInput<UnixTime>
    let feverSeverity: FeverSeverity
    let coughSeverity: CoughSeverity
    let breathlessness: Bool
    let muscleAches: Bool
    let lossSmellOrTaste: Bool
    let diarrhea: Bool
    let runnyNose: Bool
    let other: Bool
    let noSymptoms: Bool

    var durationSeconds: Int {
        Int(end.value - start.value)
    }
}
