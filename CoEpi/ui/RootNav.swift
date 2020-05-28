import UIKit
import RxSwift
import RxCocoa

class RootNav {
    let navigationCommands: PublishRelay<RootNavCommand> = PublishRelay()

    func navigate(command: RootNavCommand) {
        navigationCommands.accept(command)
    }
}

enum RootNavCommand {
    case to(destination: RootNavDestination)
    case back
    case backTo(destination: RootNavDestination)
    case backToAndTo(backDestination: RootNavDestination, toDestination: RootNavDestination)
}

enum RootNavDestination {
    case debug
    case alerts
    case thankYou
    case breathless
    case coughType
    case coughDays
    case coughDescription
    case feverDays
    case feverTemperatureTakenToday
    case feverTemperatureSpot
    case feverTemperatureSpotInput
    case feverHighestTemperature
    case symptomReport
    case SymptomStartDays
    case home
}
