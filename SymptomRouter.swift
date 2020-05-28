import Foundation


protocol SymptomRouter {
    // TODO abstract NavDirections (create NavDirections in UI), to remove Android specifics from domain
    func destination(step: SymptomStep) -> RootNavDestination
}

class SymptomRouterImpl : SymptomRouter {

    private let rootNav: RootNav

    init(rootNav: RootNav) {
        self.rootNav = rootNav
    }

    internal func destination(step to: SymptomStep) -> RootNavDestination {
        switch to {
            case .cough_type: return(.coughType)
            case .cough_days: return(.coughDays)
            case .cough_description: return(.coughDescription)
            case .breathlessness_description: return(.breathless)
            case .fever_days: return(.feverDays)
            case .fever_temperature_taken_today: return(.feverTemperatureTakenToday)
            case .fever_temperature_spot: return(.feverTemperatureSpot)
            case .fever_temperature_spot_input: return(.feverTemperatureSpotInput)
            case .fever_highest_temperature: return(.feverHighestTemperature)
            case .earliest_symptom_date: return(.SymptomStartDays)
        }
    }
}
