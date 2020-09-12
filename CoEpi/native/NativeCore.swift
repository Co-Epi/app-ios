import CryptoSwift
import Foundation

protocol AlertsApi {
    func fetchNewAlerts() -> Result<[Alert], ServicesError>
    func deleteAlert(id: String) -> Result<Void, ServicesError>
    func updateIsRead(id: String, isRead: Bool) -> Result<Void, ServicesError>
}

// For now discontinuing this approach and submitting each symptom individually.
// protocol SymptomsReporter {
//    func submitSymptoms(inputs: SymptomInputs) -> Result<(), ServicesError>
// }

protocol SymptomsInputManager {
    func setSymptoms(
        _ input: Set<SymptomId>)
        -> Result<Void, ServicesError>
    func setCoughType(
        _ input: UserInput<SymptomInputs.Cough.CoughType>)
        -> Result<Void, ServicesError>
    func setCoughDays(
        _ input: UserInput<SymptomInputs.Days>)
        -> Result<Void, ServicesError>
    func setCoughStatus(
        _ input: UserInput<SymptomInputs.Cough.Status>)
        -> Result<Void, ServicesError>
    func setBreathlessnessCause(
        _ input: UserInput<SymptomInputs.Breathlessness.Cause>)
        -> Result<Void, ServicesError>
    func setFeverDays(
        _ input: UserInput<SymptomInputs.Days>)
        -> Result<Void, ServicesError>
    func setFeverTakenTemperatureToday(
        _ input: UserInput<Bool>)
        -> Result<Void, ServicesError>
    func setFeverTakenTemperatureSpot(
        _ input: UserInput<SymptomInputs.Fever.TemperatureSpot>)
        -> Result<Void, ServicesError>
    func setFeverHighestTemperatureTaken(
        _ input: UserInput<Temperature>)
        -> Result<Void, ServicesError>
    func setEarliestSymptomStartedDaysAgo(
        _ input: UserInput<Int>)
        -> Result<Void, ServicesError>

    func submit() -> Result<Void, ServicesError>
    func clear() -> Result<Void, ServicesError>
}

protocol ServicesBootstrapper {
    func bootstrap(dbPath: String) -> Result<Void, ServicesError>
}

protocol ObservedTcnsRecorder {
    func recordTcn(tcn: Data, distance: Float) -> Result<Void, ServicesError>
}

protocol TcnGenerator {
    func generateTcn() -> Result<Data, ServicesError>
}

extension NativeCore: ServicesBootstrapper {
    // WARN: Must not run long operations. Currently executed synchronously during startup.
    func bootstrap(dbPath: String) -> Result<Void, ServicesError> {
        let registrationStatus = register_log_callback { logMessage in
            logToiOS(logMessage: logMessage)
        }
        NSLog("register_callback returned : %d", registrationStatus)
        // CoreLogLevel: 0 -> Trace, ... 4 -> Error; coepi_only logs -> true/false
        let libResult: LibResult<ArbitraryType>? =
            bootstrap_core(
                dbPath,
                CoreLogLevel(0),
                true
            )?.toLibResult()
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
    func recordTcn(tcn: Data, distance: Float) -> Result<Void, ServicesError> {
        let tcnStr = tcn.toHex()
        let libResult: LibResult<ArbitraryType>? = record_tcn(tcnStr, distance)?.toLibResult()
        return libResult?
            .toVoidResult()
            .mapErrorToServicesError() ?? libraryFailure()
    }
}

// swiftlint:disable identifier_name
struct CorePublicSymptoms: Decodable {
    let report_time: UnixTime
    let earliest_symptom_time: CoreUserInput<UnixTime>
    let fever_severity: FeverSeverity
    let cough_severity: CoughSeverity
    let breathlessness: Bool
    let muscle_aches: Bool
    let loss_smell_or_taste: Bool
    let diarrhea: Bool
    let runny_nose: Bool
    let other: Bool
    let no_symptoms: Bool
}

// swiftlint:disable identifier_name
enum FeverSeverity: String, Decodable {
    // TODO: decoding configuration to map capitalized to lower case
    case None, Mild, Serious
}

// swiftlint:disable identifier_name
enum CoughSeverity: String, Decodable {
    // TODO: decoding configuration to map capitalized to lower case
    case None, Existing, Wet, Dry
}

enum CoreUserInput<T: Decodable>: Decodable {
    case none, some(value: T)

    func map<U>(f: (T) -> U) -> UserInput<U> {
        switch self {
        case .none: return .none
        case let .some(value): return .some(f(value))
        }
    }

    func flatMap<U>(f: (T) -> UserInput<U>) -> UserInput<U> {
        switch self {
        case .none: return .none
        case let .some(value): return f(value)
        }
    }

    func toUserInput() -> UserInput<T> {
        switch self {
        case .none: return .none
        case let .some(value): return .some(value)
        }
    }
}

extension CoreUserInput {
    enum CodingError: Error { case decoding(String) }
    enum CodableKeys: String, CodingKey { case Some }

    init(from decoder: Decoder) throws {
        do {
            self = .some(value: try decoder
                .container(keyedBy: CodableKeys.self)
                .decode(T.self, forKey: .Some))
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

class NativeCore: AlertsApi {
    func fetchNewAlerts()
        -> Result<[Alert],
            ServicesError> {
        guard let libResult: LibResult<[NativeAlert]> = fetch_new_reports()?.toLibResult() else {
            return libraryFailure()
        }

        return libResult
            .toResult()
            .mapErrorToServicesError()
            .map { nativeAlerts in nativeAlerts.map {
                Alert(
                    id: $0.id,
                    reportId: $0.report_id,

                    start: UnixTime(value: Int64($0.contact_start)),
                    end: UnixTime(value: Int64($0.contact_end)),
                    minDistance: Length(value: $0.min_distance, unit: .meters),
                    avgDistance: Length(value: $0.avg_distance, unit: .meters),

                    reportTime: $0.symptoms.report_time,
                    earliestSymptomTime: $0.symptoms.earliest_symptom_time.toUserInput(),

                    feverSeverity: $0.symptoms.fever_severity,
                    coughSeverity: $0.symptoms.cough_severity,
                    breathlessness: $0.symptoms.breathlessness,
                    muscleAches: $0.symptoms.muscle_aches,
                    lossSmellOrTaste: $0.symptoms.loss_smell_or_taste,
                    diarrhea: $0.symptoms.diarrhea,
                    runnyNose: $0.symptoms.runny_nose,
                    other: $0.symptoms.other,
                    noSymptoms: $0.symptoms.no_symptoms,

                    isRead: $0.is_read
                )
            }
            }
    }

    func deleteAlert(id: String) -> Result<Void, ServicesError> {
        let libResult: LibResult<ArbitraryType>? = delete_alert(id)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func updateIsRead(id: String, isRead: Bool) -> Result<Void, ServicesError> {
        let libResult: LibResult<ArbitraryType>? =
            update_alert_is_read(id, isRead ? 1 : 0)?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    private func libraryFailure<T>() -> Result<T, ServicesError> {
        .failure(.error(message: "Couldn't get library result"))
    }
}

// For now discontinuing this approach and submitting each symptom individually.
// extension NativeCore: SymptomsReporter {
//    func submitSymptoms(inputs: SymptomInputs) -> Result<(), ServicesError> {
//        return .success(())
//    }
// }

extension NativeCore: SymptomsInputManager {
    func setSymptoms(
        _ input: Set<SymptomId>)
        -> Result<Void, ServicesError> {
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
        -> Result<Void, ServicesError> {
        let identifier: String = {
            switch input {
            case .none: return "none"
            case let .some(value): return {
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
        -> Result<Void, ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_cough_days(
            input.isSetInt,
            UInt32(input.toOptional()?.value ?? 0)
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setCoughStatus(
        _ input: UserInput<SymptomInputs.Cough.Status>)
        -> Result<Void, ServicesError> {
        let identifier: String = {
            switch input {
            case .none: return "none"
            case let .some(value): return {
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
        -> Result<Void, ServicesError> {
        let identifier: String = {
            switch input {
            case .none: return "none"
            case let .some(value): return {
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
        -> Result<Void, ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_fever_days(
            input.isSetInt,
            UInt32(input.toOptional()?.value ?? 0)
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverTakenTemperatureToday(
        _ input: UserInput<Bool>)
        -> Result<Void, ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_fever_taken_temperature_today(
            input.isSetInt,
            input.boolInt
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setFeverTakenTemperatureSpot(
        _ input: UserInput<SymptomInputs.Fever.TemperatureSpot>)
        -> Result<Void, ServicesError> {
        let identifier: String = {
            switch input {
            case .none: return "none"
            case let .some(value): return {
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
        -> Result<Void, ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_fever_highest_temperature_taken(
            input.isSetInt,
            input.toOptional()?.asFarenheit() ?? 0
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func setEarliestSymptomStartedDaysAgo(
        _ input: UserInput<Int>)
        -> Result<Void, ServicesError> {
        let libResult: LibResult<ArbitraryType>? = set_earliest_symptom_started_days_ago(
            input.isSetInt,
            UInt32(input.toOptional() ?? 0)
        )?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func submit()
        -> Result<Void, ServicesError> {
        let libResult: LibResult<ArbitraryType>? = submit_symptoms()?.toLibResult()
        return libResult?.toVoidResult().mapErrorToServicesError() ?? libraryFailure()
    }

    func clear()
        -> Result<Void,
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
        case let .some(b): return b ? 1 : 0
        case .none: return 0
        }
    }
}

// swiftlint:disable identifier_name
private struct NativeAlert: Decodable {
    let id: String
    let report_id: String
    let symptoms: CorePublicSymptoms
    let contact_start: UInt64
    let contact_end: UInt64
    let min_distance: Float32
    let avg_distance: Float32
    let is_read: Bool
}

extension Result where Failure == CoreError {
    func mapErrorToServicesError() -> Result<Success, ServicesError> {
        mapError {
            switch $0 {
            case let .error(message): return .error(message: message)
            }
        }
    }
}

public enum ServicesError: Error {
    case error(message: String)
}
