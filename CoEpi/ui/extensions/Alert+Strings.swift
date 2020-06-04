import Foundation

extension Alert {

    func breathlessnessUIString() -> String? {
        if (breathlessness) {
            return L10n.Alerts.Label.breathlessness
        } else {
            return nil
        }
    }
}

extension FeverSeverity {
    func toSymptomUIString() -> String? {
        switch self {
        case .Mild: return L10n.Alerts.Label.Fever.mild
        case .Serious: return L10n.Alerts.Label.Fever.serious
        case .None: return nil
        }
    }
}

extension CoughSeverity {
    func toSymptomUIString() -> String? {
        switch self {
        case .Dry: return L10n.Alerts.Label.Cough.dry
        case .Existing: return L10n.Alerts.Label.Cough.existing
        case .Wet: return L10n.Alerts.Label.Cough.wet
        case .None: return nil
        }
    }
}
