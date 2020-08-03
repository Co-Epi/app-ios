import Dip
import RxCocoa
import RxSwift

class CoughHowViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Cough.heading

    let setActivityIndicatorVisible: Driver<Bool>

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager

        setActivityIndicatorVisible = symptomFlowManager.submitSymptomsState
            .map { $0.isProgress() }
            .asDriver(onErrorJustReturn: false)
    }

    func onStatusSelected(status: SymptomInputs.Cough.Status) {
        symptomFlowManager.setCoughStatus(
            .some(status))
            .expect()
        symptomFlowManager.navigateForward()
    }

    func onSkipTap() {
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }
}
