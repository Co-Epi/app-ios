import Foundation
import RxSwift

class SymptomFlow {
    private var steps: [SymptomStep]

    init(steps: [SymptomStep]) {
        if steps.isEmpty {
            fatalError("Symptoms steps must not be empty")
        }
        self.steps = steps

        currentStep = self.steps.first!
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
            currentStep = step
        }
        return step
    }

    static func create(symptomIds: [SymptomId]) -> SymptomFlow? {
        if symptomIds.isEmpty {
            log.d("Symptoms ids empty")
            return nil
        }

        let steps = toSteps(symptomIds: symptomIds)
        if steps.isEmpty {
            log.d("Symptoms have no steps. Not creating a flow.")
            return nil
        }

        return SymptomFlow(steps: steps)
    }
}

private func toSteps(symptomIds: [SymptomId]) -> [SymptomStep] {
    if symptomIds.contains(.none), symptomIds.count > 1 {
        fatalError("There must be no other symptoms selected when .none is selected")
    }

    if symptomIds != [.none] {
        return symptomIds.flatMap { $0.toSteps() }

    } else {
        return []
    }
}

private extension SymptomId {
    func toSteps() -> [SymptomStep] {
        switch self {
        case .cough: return [
            .coughType,
            .coughDescription,
        ]
        case .breathlessness: return [
            .breathlessnessDescription,
        ]
        case .fever: return [
            .feverTemperatureTakenToday,
            .feverTemperatureSpot,
        ]
        case .muscleAches: return []
        case .lossSmellOrTaste: return []
        case .diarrhea: return []
        case .runnyNose: return []
        case .other: return []
        case .none: return []
        }
    }
}
