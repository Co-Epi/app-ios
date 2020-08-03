import Dip
import RxCocoa
import RxSwift

class CoughTypeViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Cough.heading

    let setActivityIndicatorVisible: Driver<Bool>

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager

        setActivityIndicatorVisible = symptomFlowManager.submitSymptomsState
            .map { $0.isProgress() }
            .asDriver(onErrorJustReturn: false)
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
