import Dip
import RxCocoa
import RxSwift
import os.log

class CoughDaysViewModel {
    private let symptomFlowManager: SymptomFlowManager
    
    private let daysIsEmpty: BehaviorRelay<Bool>
    let submitButtonEnabled: Driver<Bool>

    let title = L10n.Ux.Cough.heading

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager
        
        daysIsEmpty = BehaviorRelay<Bool>(value: true)
        
        submitButtonEnabled = daysIsEmpty
            .asObservable()
            .map{!$0}
            .asDriver(onErrorJustReturn: false)
    }

    func onDaysChanged(daysStr: String) {
        if (daysStr.isEmpty) {
            symptomFlowManager.setCoughDays(.none).expect()
        } else {
            if let days: Int = Int(daysStr) {
                symptomFlowManager.setCoughDays(.some(SymptomInputs.Days(value: days))).expect()
            } else {
                // TODO handle
                os_log("Invalid input: %{public}@ TODO handle", log: servicesLog, type: .debug, "\(daysStr)")
            }
        }
        daysIsEmpty.accept(daysStr.isEmpty)
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
