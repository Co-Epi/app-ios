import Dip
import RxCocoa
import RxSwift
import os.log

class FeverTodayViewModel {
    private let inputsManager: SymptomsInputManager

    let title = L10n.Ux.Fever.heading

    init(inputsManager: SymptomsInputManager) {
        self.inputsManager = inputsManager
    }

    func onTapYes() {
        inputsManager.setFeverTakenTemperatureToday(.some(true)).expect()
    }

    func onTapNo() {
        inputsManager.setFeverTakenTemperatureToday(.some(false)).expect()
    }
}
