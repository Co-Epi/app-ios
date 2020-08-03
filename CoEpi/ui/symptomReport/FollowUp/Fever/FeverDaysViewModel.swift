import Dip
import RxCocoa
import RxSwift

class FeverDaysViewModel {
    private let symptomFlowManager: SymptomFlowManager

    private let daysIsEmpty: BehaviorRelay<Bool>
    let submitButtonEnabled: Driver<Bool>

    let title = L10n.Ux.Fever.heading

    let setActivityIndicatorVisible: Driver<Bool>

    private let disposeBag = DisposeBag()

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager

        daysIsEmpty = BehaviorRelay<Bool>(value: true)

        submitButtonEnabled = daysIsEmpty
            .asObservable()
            .map { !$0 }
            .asDriver(onErrorJustReturn: false)

        setActivityIndicatorVisible = symptomFlowManager.submitSymptomsState
            .map { $0.isProgress() }
            .asDriver(onErrorJustReturn: false)
    }

    func onDaysChanged(daysStr: String) {
        if daysStr.isEmpty {
            symptomFlowManager.setFeverDays(.none).expect()
        } else {
            if let days: Int = Int(daysStr) {
                symptomFlowManager.setFeverDays(.some(SymptomInputs.Days(value: days))).expect()
            } else {
                // TODO: handle
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
