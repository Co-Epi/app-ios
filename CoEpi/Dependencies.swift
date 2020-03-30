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

        container.register(.eagerSingleton) { CentralImpl() as Central }
        container.register(.eagerSingleton) { PeripheralImpl() as Peripheral }

        container.register { DebugViewModel(peripheral: try container.resolve(),
                                            central: try container.resolve()) }

        container.register(.singleton) { RealmProvider() }
        container.register(.singleton) { RealmContactRepo(realmProvider: try container.resolve()) as ContactRepo }

        container.register(.singleton) { SymptomRepoImpl() as SymptomRepo }
        container.register(.singleton) { AlertRepoImpl() as AlertRepo }

        return container
    }
}
