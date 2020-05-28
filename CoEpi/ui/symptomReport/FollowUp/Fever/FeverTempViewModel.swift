import Dip
import RxCocoa
import RxSwift
import os.log

class FeverTempViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Fever.heading

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager
    }

    func onTempChanged(tempStr: String) {
        if (tempStr.isEmpty) {
            symptomFlowManager.setFeverHighestTemperatureTaken(.none).expect()
        } else {
            if let temp: Float = Float(tempStr) {
                symptomFlowManager.setFeverHighestTemperatureTaken(.some(.fahrenheit(value: temp))).expect()
            } else {
                // TODO handle
                os_log("Invalid input: %{public}@ TODO handle", log: servicesLog, type: .debug, "\(tempStr)")
            }
        }
    }

    func onSubmitTap() {
        symptomFlowManager.navigateForward()
    }

    func onUnknownTap() {
        symptomFlowManager.navigateForward()
    }

    func onSkipTap() {
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }
}
