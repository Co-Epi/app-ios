import Dip
import RxCocoa
import RxSwift
import os.log

class CoughTypeViewModel {
    private let inputsManager: SymptomsInputManager

    let title = L10n.Ux.Cough.heading

    init(inputsManager: SymptomsInputManager) {
        self.inputsManager = inputsManager
    }

    func onTapWet() {
        inputsManager.setCoughType(.some(.wet)).expect()
    }

    func onTapDry() {
        inputsManager.setCoughType(.some(.dry)).expect()
    }
}
