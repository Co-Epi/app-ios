class BreathlessViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Breathless.heading

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager
    }

    func onCauseSelected(cause: SymptomInputs.Breathlessness.Cause) {
        symptomFlowManager.setBreathlessnessCause(.some(cause)).expect()
    }

    func onSkipTap() {
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }
}
