import Dip
import RxCocoa
import RxSwift

class FeverWhereViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Fever.heading

    let setActivityIndicatorVisible: Driver<Bool>

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager

        setActivityIndicatorVisible = symptomFlowManager.submitSymptomsState
            .map { $0.isProgress() }
            .asDriver(onErrorJustReturn: false)
    }

    func onWhereSelected(spot: SymptomInputs.Fever.TemperatureSpot) {
        symptomFlowManager.setFeverTakenTemperatureSpot(.some(spot)).expect()
        forward()
    }

    func onSkipTap() {
        forward()
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }

    private func forward() {
        symptomFlowManager.navigateForward()
    }
}
