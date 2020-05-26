import Dip
import RxCocoa
import RxSwift
import os.log

class FeverTempViewModel {
    private let inputsManager: SymptomsInputManager

    let title = L10n.Ux.Fever.heading

    init(inputsManager: SymptomsInputManager) {
        self.inputsManager = inputsManager
    }

    func onTempChanged(tempStr: String) {
        if (tempStr.isEmpty) {
            inputsManager.setFeverHighestTemperatureTaken(.none).expect()
        } else {
            if let temp: Float = Float(tempStr) {
                inputsManager.setFeverHighestTemperatureTaken(.some(.fahrenheit(value: temp))).expect()
            } else {
                fatalError("Invalid input: \(tempStr)")
            }
        }
    }
}
