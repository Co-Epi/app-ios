import Foundation
import RxSwift
import os.log

protocol SymptomRepo {
    func symptoms() -> [Symptom]

    func submitSymptoms() -> Result<(), ServicesError>
}

class SymptomRepoImpl: SymptomRepo {
    private let inputManager: SymptomsInputManager

    init(inputManager: SymptomsInputManager) {
        self.inputManager = inputManager
    }

    private var symptomsData: [Symptom] = [
        Symptom(id: .fever, name: L10n.Symptom.fever),
        Symptom(id: .cough, name: L10n.Symptom.dryCough),
        Symptom(id: .muscle_aches, name: L10n.Symptom.muscleAches),
        Symptom(id: .runny_nose, name: L10n.Symptom.nasalCongestion),
        Symptom(id: .diarrhea, name: L10n.Symptom.diarrhea),
        Symptom(id: .breathlessness, name: L10n.Symptom.difficultyBreathing),
        Symptom(id: .loss_smell_or_taste, name: L10n.Symptom.lossOfSmellTaste),
        Symptom(id: .none, name: L10n.Symptom.none)
    ]
    
    func symptoms() -> [Symptom] {
        symptomsData
    }

    func submitSymptoms() -> Result<(), ServicesError> {
        inputManager.submit()
    }
}
