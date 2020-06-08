import Dip
import RxCocoa
import RxSwift

class FeverTempViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Fever.heading

    let temperatureText: Driver<String>
    let selectedTemperatureUnit: Driver<TemperatureUnit>
    let submitButtonEnabled: Driver<Bool>

    private let temperatureTrigger: PublishRelay<UserInput<Temperature>> = PublishRelay()
    private let toggleTemperatureUnitTrigger: PublishRelay<()> = PublishRelay()
    private let temperatureTextTrigger: PublishRelay<String> = PublishRelay()
    private let selectedTemperatureUnitTrigger: BehaviorRelay<TemperatureUnit> = BehaviorRelay(value: .fahrenheit)
    private let submitTrigger: PublishRelay<()> = PublishRelay()

    private let disposeBag = DisposeBag()

    init(symptomFlowManager: SymptomFlowManager) {
        self.symptomFlowManager = symptomFlowManager

        selectedTemperatureUnit = selectedTemperatureUnitTrigger
            .asDriver(onErrorJustReturn: .fahrenheit)

        let temperature = temperatureTrigger.asObservable()
        
        submitButtonEnabled = temperature
            .map{$0.toUserString()}
            .map{!$0.isEmpty}
            .asDriver(onErrorJustReturn: false)

        temperatureText = temperature
            .map { $0.toUserString() }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")

        submitTrigger.withLatestFrom(temperature)
            .subscribe(onNext: { temperature in
                symptomFlowManager.setFeverHighestTemperatureTaken(temperature).expect()
                symptomFlowManager.navigateForward()
            }).disposed(by: disposeBag)

        toggleTemperatureUnitTrigger.withLatestFrom(selectedTemperatureUnitTrigger)
            .map { $0.toggle() }
            .subscribe(onNext: { [selectedTemperatureUnitTrigger] unit in
                selectedTemperatureUnitTrigger.accept(unit)
            }).disposed(by: disposeBag)

        selectedTemperatureUnitTrigger.withLatestFrom(temperature,
                                                      resultSelector: { selectedUnit, currentTemp in
                                                        toTemperature(newUnit: selectedUnit, currentInput: currentTemp)
        })
        .subscribe(onNext: { [temperatureTrigger] newTemp in
            temperatureTrigger.accept(newTemp)
        }).disposed(by: disposeBag)

        temperatureTextTrigger.withLatestFrom(selectedTemperatureUnitTrigger.asObservable(), resultSelector: { text, unit in
            toTemperature(unit: unit, tempStr: text)
        })
        .subscribe(onNext: { [temperatureTrigger] newTemp in
            temperatureTrigger.accept(newTemp)
        }).disposed(by: disposeBag)
    }

    func onTempChanged(tempStr: String) {
        temperatureTextTrigger.accept(tempStr)
    }

    func onSubmitTap() {
        submitTrigger.accept(())
    }

    func onUnknownTap() {
        symptomFlowManager.navigateForward()
    }

    func onSkipTap() {
        symptomFlowManager.navigateForward()
    }

    func onBack() {
        symptomFlowManager.onBack()
    }

    func onTemperatureUnitPress() {
        toggleTemperatureUnitTrigger.accept(())
    }
}

private func toTemperature(unit: TemperatureUnit, tempStr: String) -> UserInput<Temperature> {
    switch tempStr {
    case "": return .none
    default:
        if let temp: Float = NumberFormatters.decimalsMax2.number(from: tempStr)?.floatValue {
            switch unit {
            case .celsius: return .some(.celsius(value: temp))
            case .fahrenheit: return .some(.fahrenheit(value: temp))
            }
        } else {
            log.w("WARN: Not numeric temperature input: \(tempStr)")
            return .none
        }
    }
}

private func toTemperature(newUnit: TemperatureUnit, currentInput: UserInput<Temperature>) -> UserInput<Temperature> {
    switch currentInput {
    case .none: return .none
    case .some(let temp): return .some(toTemperature(newUnit: newUnit, currentTemp: temp))
    }
}

private func toTemperature(newUnit: TemperatureUnit, currentTemp: Temperature) -> Temperature {
    switch newUnit {
    case .celsius:
        return .celsius(value: currentTemp.asCelsius())
    case .fahrenheit:
        return .fahrenheit(value:  currentTemp.asFarenheit())

    }
}

private extension UserInput where T == Temperature {
    func toUserString() -> String {
        switch self {
        case .none: return ""
        case .some(let temp): return temp.toUserString()
        }
    }
}

private extension TemperatureUnit {
    func toggle() -> TemperatureUnit {
        switch self {
        case .celsius: return .fahrenheit
        case .fahrenheit: return .celsius
        }
    }
}
