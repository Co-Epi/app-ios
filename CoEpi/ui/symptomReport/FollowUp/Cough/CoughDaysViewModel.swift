import Dip
import RxCocoa
import RxSwift
import os.log

class CoughDaysViewModel {

    private let inputsManager: SymptomsInputManager

    let title = L10n.Ux.Cough.heading

    init(inputsManager: SymptomsInputManager) {
        self.inputsManager = inputsManager
    }

    func onDaysChanged(daysStr: String) {
        if (daysStr.isEmpty) {
            inputsManager.setCoughDays(.none).expect()
        } else {
            if let days: Int = Int(daysStr) {
                inputsManager.setCoughDays(.some(SymptomInputs.Days(value: days))).expect()
            } else {
                fatalError("Invalid input: \(daysStr)")
            }
        }
    }
}
