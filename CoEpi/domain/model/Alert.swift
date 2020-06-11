struct Alert: AutoEquatable {
    let id: String
    let contactTime: UnixTime
    let reportTime: UnixTime
    
    let earliestSymptomTime: UserInput<UnixTime>
    let feverSeverity: FeverSeverity
    let coughSeverity: CoughSeverity
    let breathlessness: Bool
}
