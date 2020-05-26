import Foundation

protocol AlertsFetcher {
    func fetchNewAlerts() -> Result<[RawAlert], ServicesError>
}

// For now discontinuing this approach and submitting each symptom individually.
//protocol SymptomsReporter {
//    func submitSymptoms(inputs: SymptomInputs) -> Result<(), ServicesError>
//}

protocol SymptomsInputManager {
    func setSymptoms(_ input: Set<SymptomId>) -> Result<(), ServicesError>
    func setCoughType(_ input: UserInput<SymptomInputs.Cough.CoughType>) -> Result<(), ServicesError>
    func setCoughDays(_ input: UserInput<SymptomInputs.Days>) -> Result<(), ServicesError>
    func setCoughStatus(_ input: UserInput<SymptomInputs.Cough.Status>) -> Result<(), ServicesError>
    func setBreathlessnessCause(_ input: UserInput<SymptomInputs.Breathlessness.Cause>) -> Result<(), ServicesError>
    func setFeverDays(_ input: UserInput<SymptomInputs.Days>) -> Result<(), ServicesError>
    func setFeverTakenTemperatureToday(_ input: UserInput<Bool>) -> Result<(), ServicesError>
    func setFeverTakenTemperatureSpot(_ input: UserInput<SymptomInputs.Fever.TemperatureSpot>) -> Result<(), ServicesError>
    func setFeverHighestTemperatureTaken(_ input: UserInput<Temperature>) -> Result<(), ServicesError>
    func setEarliestSymptomStartedDaysAgo(_ input: UserInput<Int>) -> Result<(), ServicesError>

    func submit() -> Result<(), ServicesError>
}

protocol ServicesBootstrapper {
    func bootstrap(dbPath: String) -> Result<(), ServicesError>
}

protocol ObservedTcnsRecorder {
    func recordTcn(tcn: Data) -> Result<(), ServicesError>
}

extension NativeCore: ServicesBootstrapper {

    // WARN: Must not run long operations. Currently executed synchronously during startup.
    func bootstrap(dbPath: String) -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = bootstrap_core(dbPath)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }
}

extension NativeCore: ObservedTcnsRecorder {

    func recordTcn(tcn: Data) -> Result<(), ServicesError> {
        let tcnStr = tcn.toHex()
        let libResult: LibResult<ArbitraryType>? = record_tcn(tcnStr)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

}

class NativeCore: AlertsFetcher {

    func fetchNewAlerts() -> Result<[RawAlert], ServicesError> {
        guard let libResult: LibResult<[NativeAlert]> = fetch_new_reports()?.toLibResult() else {
            return libraryFailure()
        }

        // TODO contact time instead of .now() (see Rust)
        // TODO id (see Rust)
        // TODO memo

        return libResult.toResult().mapErrorToServicesError().map { nativeAlerts in
            nativeAlerts.map {
                RawAlert(id: $0.id, memoStr: $0.memo, contactTime: .now())
            }
        }
    }

    private func libraryFailure<T>() -> Result<T, ServicesError> {
        .failure(.error(message: "Couldn't get library result"))
    }
}

// For now discontinuing this approach and submitting each symptom individually.
//extension NativeCore: SymptomsReporter {
//    func submitSymptoms(inputs: SymptomInputs) -> Result<(), ServicesError> {
//        return .success(())
//    }
//}

extension NativeCore: SymptomsInputManager {

    func setSymptoms(_ input: Set<SymptomId>) -> Result<(), ServicesError> {

        func toStrId(id: SymptomId) -> String {
            switch id {
            case .cough: return "cough"
            case .breathlessness: return "breathlessness"
            case .fever: return "fever"
            case .muscle_aches: return "muscle_aches"
            case .loss_smell_or_taste: return "loss_smell_or_taste"
            case .diarrhea: return "diarrhea"
            case .runny_nose: return "runny_nose"
            case .other: return "other"
            case .none: return "none"
            }
        }

        let inputStrings: [String] = input.map { id in
            toStrId(id: id)
        }

        let data = try! JSONEncoder().encode(inputStrings)
        let string = String(data: data, encoding: .utf8)!

        let libResult: LibResult<ArbitraryType>? = set_symptom_ids(string)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setCoughType(_ input: UserInput<SymptomInputs.Cough.CoughType>) -> Result<(), ServicesError> {
        let identifier: String = {
            switch input {
            case .none: return "none"
            case .some(let value): return {
                switch value {
                case .dry: return "dry"
                case .wet: return "wet"
                }
            }()
            }
        }()

        let libResult: LibResult<ArbitraryType>? = set_cough_type(identifier)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setCoughDays(_ input: UserInput<SymptomInputs.Days>) -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_cough_days(
            input.isSetInt,
            UInt32(input.toOptional()?.value ?? 0)
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setCoughStatus(_ input: UserInput<SymptomInputs.Cough.Status>) -> Result<(), ServicesError> {
        let identifier: String = {
            switch input {
            case .none: return "none"
            case .some(let value): return {
                switch value {
                case .betterAndWorseThroughDay: return "better_and_worse"
                case .worseWhenOutside: return "worse_outside"
                case .sameOrSteadilyWorse: return "same_steadily_worse"
                }
            }()
            }
        }()

        let libResult: LibResult<ArbitraryType>? = set_cough_status(identifier)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setBreathlessnessCause(_ input: UserInput<SymptomInputs.Breathlessness.Cause>) -> Result<(), ServicesError> {
        let identifier: String = {
            switch input {
            case .none: return "none"
            case .some(let value): return {
                switch value {
                case .leavingHouseOrDressing: return "leaving_house_or_dressing"
                case .walkingYardsOrMinsOnGround: return "walking_yards_or_mins_on_ground"
                case .groundOwnPace: return "ground_own_pace"
                case .hurryOrHill: return "hurry_or_hill"
                case .exercise: return "exercise"
                }
            }()
            }
        }()

        let libResult: LibResult<ArbitraryType>? = set_breathlessness_cause(identifier)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverDays(_ input: UserInput<SymptomInputs.Days>) -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_fever_days(
            input.isSetInt,
            UInt32(input.toOptional()?.value ?? 0)
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverTakenTemperatureToday(_ input: UserInput<Bool>) -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_fever_taken_temperature_today(
            input.isSetInt,
            input.boolInt
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverTakenTemperatureSpot(_ input: UserInput<SymptomInputs.Fever.TemperatureSpot>) -> Result<(), ServicesError> {
        let identifier: String = {
            switch input {
            case .none: return "none"
            case .some(let value): return {
                switch value {
                case .mouth: return "mouth"
                case .ear: return "ear"
                case .armpit: return "armpit"
                case .other: return "other"
                }
            }()
            }
        }()

        let libResult: LibResult<ArbitraryType>? = set_fever_taken_temperature_spot(identifier)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverHighestTemperatureTaken(_ input: UserInput<Temperature>) -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_fever_highest_temperature_taken(
            input.isSetInt,
            input.toOptional()?.asFarenheit() ?? 0
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setEarliestSymptomStartedDaysAgo(_ input: UserInput<Int>) -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_earliest_symptom_started_days_ago(
            input.isSetInt,
            UInt32(input.toOptional() ?? 0)
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func submit() -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = submit_symptoms()?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }
}


private extension UserInput {

    var isSetInt: UInt8 {
        switch self {
        case .some: return 1
        case .none: return 0
        }
    }
}

private extension UserInput where T == Bool {

    var boolInt: UInt8 {
        switch self {
        case .some(let b): return b ? 1 : 0
        case .none: return 0
        }
    }
}

// TODO Remove NativeAlert, use directly RawAlert for Rust mapping (after adding contact time in Rust)
private struct NativeAlert: Codable {
    let id: String
    let memo: String
}

extension Result where Failure == CoreError {
    func mapErrorToServicesError() -> Result<Success, ServicesError> {
        mapError {
            switch $0 {
            case .error(let message): return .error(message: message)
            }
        }
    }
}

public enum ServicesError: Error {
    case error(message: String)
}
