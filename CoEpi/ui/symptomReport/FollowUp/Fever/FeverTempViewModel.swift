import Dip
import Foundation
import RxCocoa
import RxSwift

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

    let setActivityIndicatorVisible: Driver<Bool>

    private let disposeBag = DisposeBag()

    init(symptomFlowManager: SymptomFlowManager, unitsProvider: UnitsProvider) {
        self.symptomFlowManager = symptomFlowManager

        // Update unit text
        selectedTemperatureUnit = unitsProvider.temperatureUnit
            .map { $0.toText() }
            .asDriver(onErrorJustReturn: "")

        let temperature = temperatureTrigger.asObservable()

        submitButtonEnabled = temperature
            .map { $0.toUserString() }
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)

        // Update temperature text when temperature changes
        // (temperature can change because of input or unit change)
        temperatureText = temperature
            .map { $0.toUserString() }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")

        // Update temperature when text or unit changes
        Observable.combineLatest(
            temperatureTextTrigger,
            unitsProvider.temperatureUnit.asObservable()
        )
        .map { input, unit in
            toTemperature(unit: unit, tempStr: input)
        }
        .subscribe(onNext: { [temperatureTrigger] updatedTemp in
            temperatureTrigger.accept(updatedTemp)
        })
        .disposed(by: disposeBag)

        // Submit temperature when pressing button
        submitTrigger.withLatestFrom(temperature)
            .subscribe(onNext: { temperature in
                symptomFlowManager.setFeverHighestTemperatureTaken(temperature).expect()
                symptomFlowManager.navigateForward()
            })
            .disposed(by: disposeBag)

        setActivityIndicatorVisible = symptomFlowManager.submitSymptomsState
            .map { $0.isProgress() }
            .asDriver(onErrorJustReturn: false)
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

private func toTemperature(unit: UnitTemperature, tempStr: String) -> UserInput<Temperature> {
    switch tempStr {
    case "": return .none
    default:
        if let temp: Float = NumberFormatters.tempFormatter.number(from: tempStr)?.floatValue {
            switch unit {
            case .celsius: return .some(.celsius(value: temp))
            case .fahrenheit: return .some(.fahrenheit(value: temp))
            default:
                // See TODO in UnitsProvider.determineTemperatureUnit
                fatalError("Not supported temperature unit: \(unit)")
            }
        } else {
            log.w("WARN: Not numeric temperature input: \(tempStr)")
            return .none
        }
    }
}

private extension UnitTemperature {
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
