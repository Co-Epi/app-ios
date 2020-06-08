import Foundation
import RxSwift

class SymptomFlow {
    private var steps: [SymptomStep]

    init(steps: [SymptomStep]) {
        if (steps.isEmpty) {
            fatalError("Symptoms steps must not be empty")
        }
        self.steps = steps

        self.currentStep = self.steps.first!
    }

    private(set) var currentStep: SymptomStep

    func previous() -> SymptomStep? {
        updateStep(incr: -1)
    }

    func next() -> SymptomStep? {
        updateStep(incr: 1)
    }

    private func updateStep(incr: Int) -> SymptomStep? {
        let step = steps[safe: steps.firstIndex(of: currentStep)! + incr]
        if let step = step {
            self.currentStep = step
        }
        return step
    }

    static func create(symptomIds: [SymptomId]) -> SymptomFlow? {
        if (symptomIds.isEmpty) {
            log.d("Symptoms ids empty")
            return nil
        }

        let steps = toSteps(symptomIds: symptomIds)
        if (steps.isEmpty) {
            log.d("Symptoms have no steps. Not creating a flow.")
            return nil
        }

        return SymptomFlow(steps: steps)
    }
}

private func toSteps(symptomIds: [SymptomId]) -> [SymptomStep] {
    symptomIds.flatMap { $0.toSteps() } + [.earliest_symptom_date]
}

private extension SymptomId {
    func toSteps() -> [SymptomStep] {
        switch self {
        case .cough: return [.cough_type, .cough_days, .cough_description]
        case .breathlessness: return [.breathlessness_description]
        case .fever: return [.fever_days, .fever_temperature_taken_today, .fever_temperature_spot,
                             .fever_highest_temperature]
        case .muscle_aches: return []
        case .loss_smell_or_taste: return []
        case .diarrhea: return []
        case .runny_nose: return []
        case .other: return []
        case .none: return []
        }
    }
}
