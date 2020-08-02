import Foundation
import RxSwift

protocol SymptomRepo {
    func symptoms() -> [Symptom]

    func submitSymptoms() -> Result<Void, ServicesError>
}

class SymptomRepoImpl: SymptomRepo {
    private let inputManager: SymptomsInputManager

    init(inputManager: SymptomsInputManager) {
        self.inputManager = inputManager
    }

    private var symptomsData: [Symptom] = [
        Symptom(
            id: .none,
            name: L10n.Ux.SymptomReport.noSymptoms
        ),
        Symptom(
            id: .cough,
            name: L10n.Ux.SymptomReport.cough
        ),
        Symptom(
            id: .breathlessness,
            name: L10n.Ux.SymptomReport.breathless
        ),
        Symptom(
            id: .fever,
            name: L10n.Ux.SymptomReport.fever
        ),
        Symptom(
            id: .muscleAches,
            name: L10n.Ux.SymptomReport.ache
        ),
        Symptom(
            id: .lossSmellOrTaste,
            name: L10n.Ux.SymptomReport.loss
        ),
        Symptom(
            id: .diarrhea,
            name: L10n.Ux.SymptomReport.diarrhea
        ),
        Symptom(
            id: .runnyNose,
            name: L10n.Ux.SymptomReport.nose
        ),
        Symptom(
            id: .other,
            name: L10n.Ux.SymptomReport.other
        ),
    ]

    func symptoms() -> [Symptom] {
        symptomsData
    }

    func submitSymptoms() -> Result<Void, ServicesError> {
        inputManager.submit()
    }
}
