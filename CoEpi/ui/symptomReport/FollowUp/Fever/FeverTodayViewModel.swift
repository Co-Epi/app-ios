import Dip
import RxCocoa
import RxSwift

class FeverTodayViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Fever.heading

    let setActivityIndicatorVisible: Driver<Bool>

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager

        setActivityIndicatorVisible = symptomFlowManager.submitSymptomsState
            .map { $0.isProgress() }
            .asDriver(onErrorJustReturn: false)
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
