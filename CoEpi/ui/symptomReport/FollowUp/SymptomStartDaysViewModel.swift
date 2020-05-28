import Dip
import RxCocoa
import RxSwift
import os.log

class SymptomStartDaysViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Symptomsdays.heading

    let setActivityIndicatorVisible: Driver<Bool>

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager

        setActivityIndicatorVisible = symptomFlowManager.submitSymptomsState
            .map { $0.isProgress() }
            .asDriver(onErrorJustReturn: false)
    }

    func onDaysChanged(daysStr: String) {
        if (daysStr.isEmpty) {
            symptomFlowManager.setEarliestSymptomStartedDaysAgo(.none).expect()
        } else {
            if let days: Int = Int(daysStr) {
                symptomFlowManager.setEarliestSymptomStartedDaysAgo(.some(days)).expect()
            } else {
                // TODO handle
                os_log("Invalid input: %{public}@ TODO handle", log: servicesLog, type: .debug, "\(daysStr)")
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
