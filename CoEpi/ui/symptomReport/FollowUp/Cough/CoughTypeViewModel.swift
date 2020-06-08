import Dip
import RxCocoa
import RxSwift

class CoughTypeViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Cough.heading

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager
    }

    func onTapWet() {
        symptomFlowManager.setCoughType(.some(.wet)).expect()
        symptomFlowManager.navigateForward()
    }

    func onTapDry() {
        symptomFlowManager.setCoughType(.some(.dry)).expect()
        symptomFlowManager.navigateForward()
    }
    
    func onSkipTap() {
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }
}
