import Foundation

enum SymptomId: String, Encodable {
    case
    cough,
    breathlessness,
    fever,
    muscleAches,
    lossSmellOrTaste,
    diarrhea,
    runnyNose,
    other,
    none
}

struct SymptomInputs {
    let ids: Set<SymptomId> = Set()
    let cough: Cough = Cough()
    let breathlessness: Breathlessness = Breathlessness()
    let fever: Fever = Fever()
    let earliestSymptom: EarliestSymptom = EarliestSymptom()

    struct Cough {
        let type: UserInput<CoughType> = .none
        let days: UserInput<Days> = .none
        let status: UserInput<Status> = .none

        enum CoughType: String, Encodable {
            case
            wet,
            dry
        }

        enum Status: String, Encodable {
            case
            betterAndWorseThroughDay,
            worseWhenOutside,
            sameOrSteadilyWorse
        }
    }

    struct Breathlessness {
        let cause: UserInput<Cause> = .none

        enum Cause: String, Encodable {
            case
            leavingHouseOrDressing,
            walkingYardsOrMinsOnGround,
            groundOwnPace,
            hurryOrHill,
            exercise
        }
    }

    struct Fever {
        let days: UserInput<Days> = .none
        let takenTemperatureToday: UserInput<Bool> = .none
        let temperatureSpot: UserInput<TemperatureSpot> = .none
        let highestTemperature: UserInput<Temperature> = .none

        enum TemperatureSpot: String, Encodable {
            case
            mouth,
            ear,
            armpit,
            other
        }
    }

    struct EarliestSymptom {
        let time: UserInput<UnixTime> = .none
    }

    struct Days: Encodable { let value: Int }
}

enum UserInput<T>: AutoEquatable {
    case none, some(_ value: T)

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

    func isSome() -> Bool {
        switch self {
        case .none: return false
        case .some: return true
        }
    }

    func toOptional() -> T? {
        switch self {
        case .none: return nil
        case .some(let value): return value
        }
    }
}

enum TemperatureUnit {
    case celsius, fahrenheit
}

enum Temperature {
    case celsius(value: Float)
    case fahrenheit(value: Float)

    func asCelsius() -> Float {
        switch self {
        case .celsius(let value): return value
        case .fahrenheit(let value): return 5 / 9.0 * (value - 32)
        }
    }

    func asFarenheit() -> Float {
        switch self {
        case .fahrenheit(let value): return value
        case .celsius(let value): return 9 / 5.0 * value + 32
        }
    }

    func toUserString() -> String {
        // Force unwrap since for particular formatter and inputs, there seem to be no cases where it can return nil.
        // TODO unit tests / confirm
        NumberFormatters.tempFormatter.string(from: value)!
    }

    private var value: Float {
        switch self {
        case .celsius(let value): return value
        case .fahrenheit(let value): return value
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Experimental: This is to send the final inputs as JSON to Rust.
// For now setting each input individually. If we decide to keep this approach long term, this section can be removed.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//private enum CoreUserInput<T: Encodable>: Encodable {
//    case none, some(value: T)
//
//    func map<U>(f: (T) -> U) -> UserInput<U> {
//        switch self {
//        case .none: return .none
//        case .some(let value): return .some(f(value))
//        }
//    }
//
//    func flatMap<U> (f: (T) -> UserInput<U>) -> UserInput<U> {
//        switch self {
//        case .none: return .none
//        case .some(let value): return f(value)
//        }
//    }
//}
//
//private extension CoreUserInput {
//    enum CodingError: Error { case decoding(String) }
//    enum CodableKeys: String, CodingKey { case type, value }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodableKeys.self)
//
//         switch self {
//         case .none:
//           try container.encode("none", forKey: .type)
//         case let .some(value):
//           try container.encode("some", forKey: .type)
//           try! container.encode(value, forKey: .value)
//         }
//    }
//}
//
//private struct CoreCough: Encodable {
//    let type: CoreUserInput<SymptomInputs.Cough.CoughType>
//    let days: CoreUserInput<SymptomInputs.Days>
//    let status: CoreUserInput<SymptomInputs.Cough.Status>
//}
//
//private struct CoreBreathlessness: Encodable {
//    let cause: CoreUserInput<SymptomInputs.Breathlessness.Cause>
//}
//
//private struct CoreEarliestSymptom: Encodable {
//    let time: CoreUserInput<UnixTime>
//}
//
//private extension SymptomInputs.Cough {
//    func toCoreCough() -> CoreCough {
//        CoreCough(type: type.toCoreUserInput(), days: days.toCoreUserInput(), status: status.toCoreUserInput())
//    }
//}
//
//private extension SymptomInputs.Breathlessness {
//    func toCoreBreathlessness() -> CoreBreathlessness {
//        CoreBreathlessness(cause: cause.toCoreUserInput())
//    }
//}
//
//private extension SymptomInputs.EarliestSymptom {
//    func toCoreEarliestSymptom() -> CoreEarliestSymptom {
//        CoreEarliestSymptom(time: time.toCoreUserInput())
//    }
//}
//
//private extension SymptomInputs {
//
//    func toCoreSymptomInputs() -> CoreSymptomInputs {
//       CoreSymptomInputs(
//           ids: ids,
//           cough: cough.toCoreCough(),
//           breathlessness: breathlessness.toCoreBreathlessness(),
//           fever: CoreFever(
//                days : fever.days.toCoreUserInput(),
//                takenTemperatureToday: fever.takenTemperatureToday.toCoreUserInput(),
//                temperatureSpot: fever.temperatureSpot.toCoreUserInput(),
//                highestTemperature: fever.highestTemperature.map {
//                    FarenheitTemperature(value: $0.asFarenheit())
//                }.toCoreUserInput()
//           ),
//           earliestSymptom: earliestSymptom.toCoreEarliestSymptom()
//       )
//    }
//}
//
//private struct CoreSymptomInputs: Encodable {
//    let ids: Set<SymptomId>
//    let cough: CoreCough
//    let breathlessness: CoreBreathlessness
//    let fever: CoreFever
//    let earliestSymptom: CoreEarliestSymptom
//}
//
//private struct CoreFever: Encodable {
//    let days: CoreUserInput<SymptomInputs.Days>
//    let takenTemperatureToday: CoreUserInput<Bool>
//    let temperatureSpot: CoreUserInput<SymptomInputs.Fever.TemperatureSpot>
//    let highestTemperature: CoreUserInput<FarenheitTemperature>
//}
//
//private struct FarenheitTemperature: Encodable {
//    let value: Float
//}
//
//private extension UserInput where T: Encodable {
//    func toCoreUserInput() -> CoreUserInput<T> {
//        switch self {
//        case .none: return .none
//        case .some(let value): return .some(value: value)
//        }
//    }
//}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
