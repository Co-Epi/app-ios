import Dip
import RxCocoa
import RxSwift
import os.log

class CoughHowViewModel {

    private let inputsManager: SymptomsInputManager

    let title = L10n.Ux.Cough.heading

    init(inputsManager: SymptomsInputManager) {
        self.inputsManager = inputsManager
    }

    func onStatusSelected(status: SymptomInputs.Cough.Status) {
        inputsManager.setCoughStatus(.some(status)).expect()
    }
}
