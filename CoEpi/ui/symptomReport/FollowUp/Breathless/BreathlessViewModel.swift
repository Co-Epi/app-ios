class BreathlessViewModel {
    private let inputsManager: SymptomsInputManager

    let title = L10n.Ux.Breathless.heading

    init(inputsManager: SymptomsInputManager) {
        self.inputsManager = inputsManager
    }

    func onCauseSelected(cause: SymptomInputs.Breathlessness.Cause) {
        inputsManager.setBreathlessnessCause(.some(cause)).expect()
    }
}
