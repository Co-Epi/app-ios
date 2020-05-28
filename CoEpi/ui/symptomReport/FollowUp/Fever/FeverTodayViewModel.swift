import Dip
import RxCocoa
import RxSwift
import os.log

class FeverTodayViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Fever.heading

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager
    }

    func onYesTap() {
        symptomFlowManager.setFeverTakenTemperatureToday(.some(true)).expect()
        symptomFlowManager.navigateForward()
    }

    func onNoTap() {
        symptomFlowManager.setFeverTakenTemperatureToday(.some(false)).expect()
        symptomFlowManager.navigateForward()
    }

    func onSkipTap() {
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }
}
