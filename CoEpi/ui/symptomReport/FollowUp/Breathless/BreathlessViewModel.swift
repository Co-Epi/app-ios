import RxSwift
import RxCocoa

struct BreathlessItemViewData {
    let imageName: String
    let text: String
    let cause: SymptomInputs.Breathlessness.Cause
}

class BreathlessViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Breathless.heading

    let viewData: Driver<[BreathlessItemViewData]>

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager

        viewData = Observable.just([
            BreathlessItemViewData(imageName: "house", text: L10n.Ux.Breathless.p0, cause: .leavingHouseOrDressing),
            BreathlessItemViewData(imageName: "stop", text: L10n.Ux.Breathless.p1, cause:  .walkingYardsOrMinsOnGround),
            BreathlessItemViewData(imageName: "ground", text: L10n.Ux.Breathless.p2, cause: .groundOwnPace),
            BreathlessItemViewData(imageName: "hill", text: L10n.Ux.Breathless.p3, cause: .hurryOrHill),
            BreathlessItemViewData(imageName: "exercise", text: L10n.Ux.Breathless.p4, cause: .exercise)
       ]).asDriver(onErrorJustReturn: [])
    }

    func onCauseSelected(viewData: BreathlessItemViewData) {
        symptomFlowManager.setBreathlessnessCause(.some(viewData.cause)).expect()
        symptomFlowManager.navigateForward()
    }

    func onSkipTap() {
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }
}
