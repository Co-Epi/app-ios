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
        // NOTE: temporary: specs are unstable and were changed to not enter temperature value
        // for now we'll submit this fake value to trigger "has fever" in the alerts.
        // if value input is permanently removed, we should change core to process only a boolean flag
        log.i("NOTE: intentionally submitting fake fever temperature (100F)")
        symptomFlowManager.setFeverHighestTemperatureTaken(.some(.fahrenheit(value: 100)))
            .expect()

        symptomFlowManager.navigateForward()
    }
}
