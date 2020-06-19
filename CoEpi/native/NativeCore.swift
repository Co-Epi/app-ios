import Foundation
import CryptoSwift

protocol AlertsFetcher {
    func fetchNewAlerts() -> Result<[Alert], ServicesError>
}

// For now discontinuing this approach and submitting each symptom individually.
//protocol SymptomsReporter {
//    func submitSymptoms(inputs: SymptomInputs) -> Result<(), ServicesError>
//}

protocol SymptomsInputManager {
    func setSymptoms(
        _ input: Set<SymptomId>)
        -> Result<(), ServicesError>
    func setCoughType(
        _ input: UserInput<SymptomInputs.Cough.CoughType>)
        -> Result<(), ServicesError>
    func setCoughDays(
        _ input: UserInput<SymptomInputs.Days>)
        -> Result<(), ServicesError>
    func setCoughStatus(
        _ input: UserInput<SymptomInputs.Cough.Status>)
        -> Result<(), ServicesError>
    func setBreathlessnessCause(
        _ input: UserInput<SymptomInputs.Breathlessness.Cause>)
        -> Result<(), ServicesError>
    func setFeverDays(
        _ input: UserInput<SymptomInputs.Days>)
        -> Result<(), ServicesError>
    func setFeverTakenTemperatureToday(
        _ input: UserInput<Bool>)
        -> Result<(), ServicesError>
    func setFeverTakenTemperatureSpot(
        _ input: UserInput<SymptomInputs.Fever.TemperatureSpot>)
        -> Result<(), ServicesError>
    func setFeverHighestTemperatureTaken(
        _ input: UserInput<Temperature>)
        -> Result<(), ServicesError>
    func setEarliestSymptomStartedDaysAgo(
        _ input: UserInput<Int>)
        -> Result<(), ServicesError>

    func submit() -> Result<(), ServicesError>
    func clear() -> Result<(), ServicesError>
}

protocol ServicesBootstrapper {
    func bootstrap(dbPath: String) -> Result<(), ServicesError>
}

protocol ObservedTcnsRecorder {
    func recordTcn(tcn: Data) -> Result<(), ServicesError>
}

protocol TcnGenerator {
    func generateTcn() -> Result<Data, ServicesError>
}

extension NativeCore: ServicesBootstrapper {

    // WARN: Must not run long operations. Currently executed synchronously during startup.
    func bootstrap(dbPath: String) -> Result<(), ServicesError> {
        let registrationStatus = register_log_callback { (logMessage) in
            logToiOS(logMessage: logMessage)
        }
        NSLog("register_callback returned : %d", registrationStatus )
         //CoreLogLevel: 0 -> Trace, ... 4 -> Error; coepi_only logs -> true/false
        let libResult: LibResult<ArbitraryType>? =
            bootstrap_core(
            dbPath,
            CoreLogLevel.init(0),
            true)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }
}

func logToiOS(logMessage: CoreLogMessage) {
    guard let unmanagedText: Unmanaged<CFString> = logMessage.text else {
        return
    }
    let text = unmanagedText.takeRetainedValue() as String

    switch logMessage.level {
    case 0:
        log.v(text, tags: LogTag.core)
    case 1:
        log.d(text, tags: LogTag.core)
    case 2:
        log.i(text, tags: LogTag.core)
    case 3:
        log.w(text, tags: LogTag.core)
    case 4:
        log.e(text, tags: LogTag.core)
    default:
        log.i(text, tags: LogTag.core)
    }

}

extension NativeCore: ObservedTcnsRecorder {
    func recordTcn(tcn: Data) -> Result<(), ServicesError> {
        let tcnStr = tcn.toHex()
        let libResult: LibResult<ArbitraryType>? = record_tcn(tcnStr)?.toLibResult()
        return libResult?
            .toVoidResult()
            .mapErrorToServicesError() ?? libraryFailure()
    }
}

struct CorePublicReport: Decodable {
    let reportTime: UnixTime
    let earliestSymptomTime: CoreUserInput<UnixTime>
    let feverSeverity: FeverSeverity
    let coughSeverity: CoughSeverity
    let breathlessness: Bool
    let muscleAches: Bool
    let lossSmellOrTaste: Bool
    let diarrhea: Bool
    let runnyNose: Bool
    let other: Bool
    let noSymptoms: Bool
}

enum FeverSeverity: String, Decodable {
  // TODO decoding configuration to map capitalized to lower case
  case none, mild, serious
}

enum CoughSeverity: String, Decodable {
// TODO decoding configuration to map capitalized to lower case
  case none, existing, wet, dry
}

enum CoreUserInput<T: Decodable>: Decodable {
    case none, some(value: T)

    func map<U>(f: (T) -> U) -> UserInput<U> {
        switch self {
        case .none: return .none
        case .some(let value): return .some(f(value))
        }
    }

    func flatMap<U> (f: (T) -> UserInput<U>) -> UserInput<U> {
        switch self {
        case .none: return .none
        case .some(let value): return f(value)
        }
    }

    func toUserInput() -> UserInput<T> {
        switch self {
        case .none: return .none
        case .some(let value): return .some(value)
        }
    }
}

extension CoreUserInput {
    enum CodingError: Error { case decoding(String) }
    enum CodableKeys: String, CodingKey { case some }

    init(from decoder: Decoder) throws {
        do {
            self = .some(value: try decoder
                .container(keyedBy: CodableKeys.self)
                .decode(T.self, forKey: .some))
        } catch let decodingSomeError {
            do {
                let value = try decoder.singleValueContainer().decode(String.self)
                if value != "None" {
                    throw CodingError.decoding(value)
                }
                self = .none
            } catch let decodingNoneError {
                throw CodingError.decoding(
                    "Wasn't able to decode user input: To Some: \(decodingSomeError), To None: "
                        + "\(decodingNoneError)")
            }
        }
    }
}

class NativeCore: AlertsFetcher {

    func fetchNewAlerts()
        -> Result<[Alert],
        ServicesError> {
        guard let libResult: LibResult<[NativeAlert]> = fetch_new_reports()?.toLibResult() else {
            return libraryFailure()
        }

        // TODO id (see Rust)

        return libResult
            .toResult()
            .mapErrorToServicesError()
            .map { nativeAlerts in
            return nativeAlerts.map {
                Alert(
                    id: $0.id,
                    // Using UInt64 for time in Rust, as stylistic preference, as we can't have a negative timestamp.
                    // UInt64 can be safely converted to Int64 for unix time.
                    // Consider using UInt64 here too, for consistency.
                    contactTime: UnixTime.init(value: Int64($0.contactTime)),
                    reportTime: $0.report.reportTime,
                    earliestSymptomTime: $0.report.earliestSymptomTime.toUserInput(),
                    feverSeverity: $0.report.feverSeverity,
                    coughSeverity: $0.report.coughSeverity,
                    breathlessness: $0.report.breathlessness,
                    muscleAches: $0.report.muscleAches,
                    lossSmellOrTaste: $0.report.lossSmellOrTaste,
                    diarrhea: $0.report.diarrhea,
                    runnyNose: $0.report.runnyNose,
                    other: $0.report.other,
                    noSymptoms: $0.report.noSymptoms
                )
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

    func setSymptoms(
        _ input: Set<SymptomId>)
        -> Result<(), ServicesError> {

        func toStrId(id: SymptomId) -> String {
            switch id {
            case .cough: return "cough"
            case .breathlessness: return "breathlessness"
            case .fever: return "fever"
            case .muscleAches: return "muscle_aches"
            case .lossSmellOrTaste: return "loss_smell_or_taste"
            case .diarrhea: return "diarrhea"
            case .runnyNose: return "runny_nose"
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

    func setCoughType(
        _ input: UserInput<SymptomInputs.Cough.CoughType>)
        -> Result<(), ServicesError> {
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

    func setCoughDays(
        _ input: UserInput<SymptomInputs.Days>)
        -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_cough_days(
            input.isSetInt,
            UInt32(input.toOptional()?.value ?? 0)
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setCoughStatus(
        _ input: UserInput<SymptomInputs.Cough.Status>)
        -> Result<(), ServicesError> {
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

    func setBreathlessnessCause(
        _ input: UserInput<SymptomInputs.Breathlessness.Cause>)
        -> Result<(), ServicesError> {
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

        let libResult: LibResult<ArbitraryType>? = set_breathlessness_cause(identifier)?
            .toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverDays(
        _ input: UserInput<SymptomInputs.Days>)
        -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_fever_days(
            input.isSetInt,
            UInt32(input.toOptional()?.value ?? 0)
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverTakenTemperatureToday(
        _ input: UserInput<Bool>)
        -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_fever_taken_temperature_today(
            input.isSetInt,
            input.boolInt
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverTakenTemperatureSpot(
        _ input: UserInput<SymptomInputs.Fever.TemperatureSpot>)
        -> Result<(), ServicesError> {
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

        let libResult: LibResult<ArbitraryType>? = set_fever_taken_temperature_spot(identifier)?
            .toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverHighestTemperatureTaken(
        _ input: UserInput<Temperature>)
        -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_fever_highest_temperature_taken(
            input.isSetInt,
            input.toOptional()?.asFarenheit() ?? 0
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setEarliestSymptomStartedDaysAgo(
        _ input: UserInput<Int>)
        -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_earliest_symptom_started_days_ago(
            input.isSetInt,
            UInt32(input.toOptional() ?? 0)
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func submit()
        -> Result<(), ServicesError> {
        let libResult: LibResult<ArbitraryType>? = submit_symptoms()?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func clear()
        -> Result<(),
        ServicesError> {
        let libResult: LibResult<ArbitraryType>? = clear_symptoms()?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }
}

extension NativeCore: TcnGenerator {
    func generateTcn()
        -> Result<Data, ServicesError> {
        guard let resultValue: Unmanaged<CFString> = generate_tcn() else {
            return libraryFailure()
        }
        let tcnHex = resultValue.takeRetainedValue() as String
        return .success(Data(hex: tcnHex))
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

private struct NativeAlert: Decodable {
    let id: String
    let report: CorePublicReport
    let contactTime: UInt64
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
