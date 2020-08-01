import RxSwift
import RxCocoa
import SwiftUI

struct BreathlessItemViewData {
    let imageName: String
    let text: String
    let cause: SymptomInputs.Breathlessness.Cause
}

class BreathlessViewModel: ObservableObject {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Breathless.heading

    let viewData: [BreathlessItemViewData]

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager

        let breath = L10n.Ux.Breathless.self

        viewData = [
            BreathlessItemViewData(
                imageName: "house",
                text: breath.p0,
                cause: .leavingHouseOrDressing),
            BreathlessItemViewData(
                imageName: "stop",
                text: breath.p1,
                cause: .walkingYardsOrMinsOnGround),
            BreathlessItemViewData(
                imageName: "ground",
                text: breath.p2,
                cause: .groundOwnPace),
            BreathlessItemViewData(
                imageName: "hill",
                text: breath.p3,
                cause: .hurryOrHill),
            BreathlessItemViewData(
                imageName: "exercise",
                text: breath.p4,
                cause: .exercise)
       ]
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
