struct Alert {
    let id: String
    let contactTime: UnixTime

    let earliestSymptomTime: UserInput<UnixTime>
    let feverSeverity: FeverSeverity
    let coughSeverity: CoughSeverity
    let breathlessness: Bool
}
