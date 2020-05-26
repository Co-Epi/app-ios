import Dip
import RxCocoa
import RxSwift
import os.log

class FeverDaysViewModel{
    private let inputsManager: SymptomsInputManager

    let title = L10n.Ux.Fever.heading

    init(inputsManager: SymptomsInputManager) {
        self.inputsManager = inputsManager
    }

    func onDaysChanged(daysStr: String) {
        if (daysStr.isEmpty) {
            inputsManager.setFeverDays(.none).expect()
        } else {
            if let days: Int = Int(daysStr) {
                inputsManager.setFeverDays(.some(SymptomInputs.Days(value: days))).expect()
            } else {
                fatalError("Invalid input: \(daysStr)")
            }
        }
    }
}
