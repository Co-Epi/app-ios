////not sure how?

//import Foundation
//
//
//
//enum SymptomId {
//    case COUGH
//    case BREATHLESSNESS
//    case FEVER
//    case MUSCLE_ACHES
//    case LOSS_SMELL_OR_TASTE
//    case DIARRHEA
//    case RUNNY_NOSE
//    case OTHER
//    case NONE
//    case EARLIESTSYMPTOM
//    func toSteps() -> Array<SymptomStep>{
//        switch self {
//            case .COUGH: return([.COUGH_TYPE, .COUGH_DAYS, .COUGH_DESCRIPTION])
//            case .BREATHLESSNESS: return([.BREATHLESSNESS_DESCRIPTION])
//            case .FEVER: return([.FEVER_DAYS, .FEVER_TEMPERATURE_TAKEN_TODAY, .FEVER_TEMPERATURE_SPOT, .FEVER_HIGHEST_TEMPERATURE])
//            case .MUSCLE_ACHES: return[]
//            case .LOSS_SMELL_OR_TASTE: return([])
//            case .DIARRHEA: return([])
//            case .RUNNY_NOSE: return([])
//            case .OTHER: return([])
//            case .NONE: return([])
//            case .EARLIESTSYMPTOM: return([.EARLIEST_SYMPTOM_DATE])
//        }
//    }
//}
//
//
//
//
//
//struct SymptomInputs{
//    var ids = Set<SymptomId>()
//    var cough: Cough = Cough()
//    var breathlessness: Breathlessness = Breathlessness()
//    var fever: Fever = Fever()
//    var earliestSymptomDate: EarliestSymptom = EarliestSymptom()
//
//
//    struct Cough{
//        var type: UserInput<coughType>? = nil
//        var days: UserInput<Days>? = nil
//        var status: UserInput<Status>? = nil
//
//
//
//        enum coughType {
//            case WET
//            case DRY }
//
//
//        enum Status {
//            case BETTER_AND_WORSE_THROUGH_DAY
//            case WORSE_WHEN_OUTSIDE
//            case SAME_OR_STEADILY_WORSE
//        }
//
//        struct Days{var value: Int}
//    }
//
//
//    struct Breathlessness{
//        var cause: UserInput<Cause>? = nil
//
//        enum Cause {
//            case LEAVING_HOUSE_OR_DRESSING
//            case WALKING_YARDS_OR_MINS_ON_GROUND
//            case GROUND_OWN_PACE
//            case HURRY_OR_HILL
//            case EXERCISE
//        }
//    }
//
//
//    struct Fever{
//        var days: UserInput<Days>? = nil
//        var takenTemperatureToday: UserInput<DarwinBoolean>? = nil
//        var temperatureSpot: UserInput<TemperatureSpot>? = nil
//        var highestTemperature: UserInput<Temperature>? = nil
//
//        struct Days{var value: Int}
//
//        enum TemperatureSpot{
//            case Mouth
//            case Ear
//            case Armpit
//            case Other(String)
//            }
//        }
//    }
//
//    struct EarliestSymptom{
//        var days: UserInput<Days>? = nil
//        struct Days{var value: Int}
//    }
//
//
////not sure how?
////// Ideally the type parameter would have been Parcelable, but we want to allow primitives too.
////sealed class UserInput<out T : Serializable> : Parcelable {
////
////    object None : UserInput<Nothing>(), Parcelable
////
////
////    data class Some<T : Serializable>(val value: T) : UserInput<T>(), Parcelable
////}
////
////data class Temperature(val value: Float) : Serializable
////
