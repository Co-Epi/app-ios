import Foundation
import RxSwift
import os.log

protocol SymptomRepo {
    func symptoms() -> [Symptom]

    func submitSymptoms(symptoms: [Symptom]) -> Completable
}

class SymptomRepoImpl: SymptomRepo {
    private let coEpiRepo: CoEpiRepo

    init(coEpiRepo: CoEpiRepo) {
        self.coEpiRepo = coEpiRepo
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

    func submitSymptoms(symptoms: [Symptom]) -> Completable {
        if let cenReport = symptoms.toCENReport() {
            return coEpiRepo.sendReport(report: cenReport)
        } else {
            os_log("Couldn't encode symptoms: %@ to Base64", log: servicesLog, type: .debug, "\(symptoms)")
            return Completable.error(RepoError.unknown)
        }
    }
}

private extension Sequence where Iterator.Element == Symptom {
    func toCENReport() -> CenReport? {
        let stringReport : String  = map { $0.name }.joined(separator: ", ")
        return CenReport(id: UUID().uuidString, report: stringReport, timestamp: UnixTime.now().value)
    }
}
