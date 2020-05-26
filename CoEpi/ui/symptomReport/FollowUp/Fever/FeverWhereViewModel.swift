import Dip
import RxCocoa
import RxSwift
import os.log

class FeverWhereViewModel {
    private let inputsManager: SymptomsInputManager

    let title = L10n.Ux.Fever.heading

    init(inputsManager: SymptomsInputManager) {
        self.inputsManager = inputsManager
    }

    func onWhereSelected(spot: SymptomInputs.Fever.TemperatureSpot) {
        inputsManager.setFeverTakenTemperatureSpot(.some(spot)).expect()
    }
}
