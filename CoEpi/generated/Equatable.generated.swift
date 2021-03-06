// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// MARK: Alert Equatable
extension Alert: Equatable {
    static func ==(lhs: Alert, rhs: Alert) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.reportId == rhs.reportId else { return false }
        guard lhs.start == rhs.start else { return false }
        guard lhs.end == rhs.end else { return false }
        guard lhs.minDistance == rhs.minDistance else { return false }
        guard lhs.avgDistance == rhs.avgDistance else { return false }
        guard lhs.reportTime == rhs.reportTime else { return false }
        guard lhs.earliestSymptomTime == rhs.earliestSymptomTime else { return false }
        guard lhs.feverSeverity == rhs.feverSeverity else { return false }
        guard lhs.coughSeverity == rhs.coughSeverity else { return false }
        guard lhs.breathlessness == rhs.breathlessness else { return false }
        guard lhs.muscleAches == rhs.muscleAches else { return false }
        guard lhs.lossSmellOrTaste == rhs.lossSmellOrTaste else { return false }
        guard lhs.diarrhea == rhs.diarrhea else { return false }
        guard lhs.runnyNose == rhs.runnyNose else { return false }
        guard lhs.other == rhs.other else { return false }
        guard lhs.noSymptoms == rhs.noSymptoms else { return false }
        guard lhs.isRead == rhs.isRead else { return false }
        return true
    }
}
// MARK: AlertViewData Equatable
extension AlertViewData: Equatable {
    static func ==(lhs: AlertViewData, rhs: AlertViewData) -> Bool {
        guard lhs.symptoms == rhs.symptoms else { return false }
        guard lhs.contactTime == rhs.contactTime else { return false }
        guard lhs.showUnreadDot == rhs.showUnreadDot else { return false }
        guard lhs.showRepeatedInteraction == rhs.showRepeatedInteraction else { return false }
        guard lhs.alert == rhs.alert else { return false }
        return true
    }
}
// MARK: Length Equatable
extension Length: Equatable {
    static func ==(lhs: Length, rhs: Length) -> Bool {
        guard lhs.value == rhs.value else { return false }
        guard lhs.unit == rhs.unit else { return false }
        return true
    }
}
// MARK: UnixTime Equatable
extension UnixTime: Equatable {
    static func ==(lhs: UnixTime, rhs: UnixTime) -> Bool {
        guard lhs.value == rhs.value else { return false }
        return true
    }
}
// MARK: UserInput Equatable
extension UserInput: Equatable {
    static func ==(lhs: UserInput, rhs: UserInput) -> Bool {
        return true
    }
}
