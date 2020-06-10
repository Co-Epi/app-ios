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
            case .coughType: return(.coughType)
            case .coughDays: return(.coughDays)
            case .coughDescription: return(.coughDescription)
            case .breathlessnessDescription: return(.breathless)
            case .feverDays: return(.feverDays)
            case .feverTemperatureTakenToday: return(.feverTemperatureTakenToday)
            case .feverTemperatureSpot: return(.feverTemperatureSpot)
            case .feverHighestTemperature: return(.feverHighestTemperature)
            case .earliestSymptomDate: return(.symptomStartDays)
        }
    }
}
