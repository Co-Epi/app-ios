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
}

enum RootNavDestination {
    case quiz
    case debug
    case alerts
}

