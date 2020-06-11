// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// MARK: Alert Equatable
extension Alert: Equatable {
    static func ==(lhs: Alert, rhs: Alert) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.contactTime == rhs.contactTime else { return false }
        guard lhs.reportTime == rhs.reportTime else { return false }
        guard lhs.earliestSymptomTime == rhs.earliestSymptomTime else { return false }
        guard lhs.feverSeverity == rhs.feverSeverity else { return false }
        guard lhs.coughSeverity == rhs.coughSeverity else { return false }
        guard lhs.breathlessness == rhs.breathlessness else { return false }
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
