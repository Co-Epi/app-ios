import Foundation

extension Alert {
    func symptomUIStrings() -> [String] {
        [
            coughSeverity.toSymptomUIString(),
            breathlessness ? L10n.Alerts.Label.Symptom.breathlessness : nil,
            feverSeverity.toSymptomUIString(),
            muscleAches ? L10n.Alerts.Label.Symptom.muscleAches : nil,
            lossSmellOrTaste ? L10n.Alerts.Label.Symptom.lossSmellOrTaste : nil,
            diarrhea ? L10n.Alerts.Label.Symptom.diarrhea : nil,
            runnyNose ? L10n.Alerts.Label.Symptom.runnyNose : nil,
            other ? L10n.Alerts.Label.Symptom.other : nil,
            noSymptoms ? L10n.Alerts.Label.Symptom.noSymptomsReported : nil,
        ].compactMap { $0 }
    }
}

extension FeverSeverity {
    func toSymptomUIString() -> String? {
        switch self {
        case .Mild: return L10n.Alerts.Label.Symptom.Fever.mild
        case .Serious: return L10n.Alerts.Label.Symptom.Fever.serious
        case .None: return nil
        }
    }
}

extension CoughSeverity {
    func toSymptomUIString() -> String? {
        switch self {
        case .Dry: return L10n.Alerts.Label.Symptom.Cough.dry
        case .Existing: return L10n.Alerts.Label.Symptom.Cough.existing
        case .Wet: return L10n.Alerts.Label.Symptom.Cough.wet
        case .None: return nil
        }
    }
}
