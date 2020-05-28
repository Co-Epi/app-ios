import Dip
import RxCocoa
import RxSwift
import os.log

class CoughHowViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Cough.heading

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager
    }

    func onStatusSelected(status: SymptomInputs.Cough.Status) {
        symptomFlowManager.setCoughStatus(.some(status)).expect()
        symptomFlowManager.navigateForward()
    }

    func onSkipTap() {
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }
}
