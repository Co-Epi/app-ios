import Dip
import RxCocoa
import RxSwift

class SymptomStartDaysViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Symptomsdays.heading

    let setActivityIndicatorVisible: Driver<Bool>
    
    private let daysIsEmpty: BehaviorRelay<Bool>
    let submitButtonEnabled: Driver<Bool>

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager
        
        daysIsEmpty = BehaviorRelay<Bool>(value: true)
        
        submitButtonEnabled = daysIsEmpty
            .asObservable()
            .map{!$0}
            .asDriver(onErrorJustReturn: false)

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
                log.d("Invalid input: \(daysStr) TODO handle")
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
