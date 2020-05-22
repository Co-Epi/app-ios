import Foundation
import RxSwift
import os.log

protocol SymptomRepo {
    func symptoms() -> [Symptom]

    func submitSymptoms(symptoms: [Symptom]) -> Result<(), ServicesError>
}

class SymptomRepoImpl: SymptomRepo {
    private let symptomsReporter: SymptomsReporter

    init(symptomsReporter: SymptomsReporter) {
        self.symptomsReporter = symptomsReporter
    }

    private var symptomsData: [Symptom] = [
        Symptom(id: "1", name: L10n.Symptom.fever),
        Symptom(id: "2", name: L10n.Symptom.tiredness),
        Symptom(id: "3", name: L10n.Symptom.dryCough),
        Symptom(id: "4", name: L10n.Symptom.muscleAches),
        Symptom(id: "5", name: L10n.Symptom.nasalCongestion),
        Symptom(id: "6", name: L10n.Symptom.runnyNose),
        Symptom(id: "7", name: L10n.Symptom.soreThroat),
        Symptom(id: "8", name: L10n.Symptom.diarrhea),
        Symptom(id: "9", name: L10n.Symptom.difficultyBreathing),
        Symptom(id: "10", name: L10n.Symptom.lossOfSmellTaste),
        Symptom(id: "11", name: L10n.Symptom.none)
    ]
    
    func symptoms() -> [Symptom] {
        symptomsData
    }

    func submitSymptoms(symptoms: [Symptom]) -> Result<(), ServicesError> {
        // TODO
        // 1. Port symptom inputs aggregate from Android (1:1)
        // 2. Implement inputs processing in Rust
        // 3. Send here inputs to Rust
        // Possible improvement: Set individual symptoms in Rust directly, so we don't have to maintain inputs aggregate here
        // this may not work well with current JSON based api though as serializing/deserializing adds some overhead
        // can be resumed when Rust integration is more stable and we switch to non-JSON payload
        symptomsReporter.postCenReport(myCenReport: MyCenReport(
            id: "not used",
            report: CenReport(id: "not used", report: "not used", timestamp: UnixTime.now().value),
            keys: []
        ))
    }
}
