import Dip
import RxCocoa
import RxSwift
import Foundation

class FeverTempViewModel {
    private let symptomFlowManager: SymptomFlowManager

    let title = L10n.Ux.Fever.heading

    let temperatureText: Driver<String>
    let selectedTemperatureUnit: Driver<String>
    let submitButtonEnabled: Driver<Bool>

    private let temperatureTrigger: PublishRelay<UserInput<Temperature>> = PublishRelay()
    private let temperatureTextTrigger: PublishRelay<String> = PublishRelay()
    private let tempUnitTrigger: BehaviorRelay<TemperatureUnit> = BehaviorRelay(value: .fahrenheit)
    private let submitTrigger: PublishRelay<Void> = PublishRelay()

    private let disposeBag = DisposeBag()

    init(symptomFlowManager: SymptomFlowManager, unitsProvider: UnitsProvider) {
        self.symptomFlowManager = symptomFlowManager

        selectedTemperatureUnit = tempUnitTrigger
            .map { $0.toText() }
            .asDriver(onErrorJustReturn: "")

        let temperature = temperatureTrigger.asObservable()

        submitButtonEnabled = temperature
            .map { $0.toUserString() }
            .map { !$0.isEmpty }
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

        unitsProvider.temperatureUnit.withLatestFrom(
            temperature, resultSelector: { selectedUnit, currentTemp in
                toTemperature(newUnit: selectedUnit, currentInput: currentTemp)
            }
        )
        .subscribe(onNext: { [temperatureTrigger] newTemp in
            temperatureTrigger.accept(newTemp)
        }).disposed(by: disposeBag)

        temperatureTextTrigger.withLatestFrom(
            tempUnitTrigger.asObservable(),
            resultSelector: { text, unit in
                toTemperature(unit: unit, tempStr: text)
            }
        )
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
}

private func toTemperature(unit: TemperatureUnit, tempStr: String) -> UserInput<Temperature> {
    switch tempStr {
    case "": return .none
    default:
        if let temp: Float = NumberFormatters.tempFormatter.number(from: tempStr)?.floatValue {
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

private func toTemperature(
    newUnit: UnitTemperature,
    currentInput: UserInput<Temperature>
) -> UserInput<Temperature> {
    switch currentInput {
    case .none: return .none
    case let .some(temp): return .some(toTemperature(newUnit: newUnit, currentTemp: temp))
    }
}

private func toTemperature(newUnit: UnitTemperature, currentTemp: Temperature) -> Temperature {
    switch newUnit {
    case .celsius:
        return .celsius(value: currentTemp.asCelsius())
    case .fahrenheit:
        return .fahrenheit(value: currentTemp.asFarenheit())
    default:
        // See TODO in UnitsProvider.determineTemperatureUnit
        fatalError("Not supported temperature unit: \(newUnit)")
    }
}

private extension TemperatureUnit {
    func toText() -> String {
        switch self {
        case .celsius:
            return L10n.Ux.Fever.c
        case .fahrenheit:
            return L10n.Ux.Fever.f
        default:
            // See TODO in UnitsProvider.determineTemperatureUnit
            fatalError("Not supported temperature unit: \(self)")
        }
    }
}

private extension UserInput where T == Temperature {
    func toUserString() -> String {
        switch self {
        case .none: return ""
        case let .some(temp): return temp.toUserString()
        }
    }
}
