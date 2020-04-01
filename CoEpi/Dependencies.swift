import Foundation
import Dip

class Dependencies {

    func createContainer() -> DependencyContainer {
        let container = DependencyContainer()

        container.register { HomeViewModel() }
        container.register { OnboardingWireframe(container: container) }
        container.register { OnboardingViewModel() }
        container.register { HealthQuizViewModel(container: container) }
        container.register { AlertsViewModel(container: container) }

        container.register { ContactReceivedHandler(cenKeyRepo: try container.resolve()) as PeripheralRequestHandler }
        container.register(.eagerSingleton) { CentralImpl() as CentralReactive }
        container.register(.eagerSingleton) { PeripheralImpl(internalDelegate: try container.resolve()) as PeripheralReactive }

        container.register { DebugViewModel(peripheral: try container.resolve(),
                                            central: try container.resolve()) }

        container.register(.singleton) { RealmProvider() }
        container.register(.singleton) { RealmCENRepo(realmProvider: try container.resolve()) as CENRepo }
        container.register(.singleton) { RealmCENReportRepo(realmProvider: try container.resolve()) as CENReportRepo }
        container.register(.singleton) { RealmCENKeyRepo(realmProvider: try container.resolve()) as CENKeyRepo }

        container.register(.singleton) { SymptomRepoImpl() as SymptomRepo }
        container.register(.singleton) { AlertRepoImpl() as AlertRepo }

        return container
    }
}
