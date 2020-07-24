import Dip
import RxCocoa
import RxSwift

class FeverWhereViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Fever.heading

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager
    }

    func onWhereSelected(spot: SymptomInputs.Fever.TemperatureSpot) {
        symptomFlowManager.setFeverTakenTemperatureSpot(.some(spot)).expect()
        symptomFlowManager.navigateForward()
    }

    func onSkipTap() {
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }
}
