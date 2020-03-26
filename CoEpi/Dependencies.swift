import Foundation
import Dip

class Dependencies {

    func createContainer() -> DependencyContainer {
        let container = DependencyContainer()

        container.register { HomeViewModel() }
        container.register { OnboardingWireframe(container: container) }
        container.register { OnboardingViewModel() }

        container.register(.eagerSingleton) { CentralImpl() as Central }
        container.register(.eagerSingleton) { PeripheralImpl() as Peripheral }

        container.register { DebugViewModelImpl(peripheral: try container.resolve(),
                                                central: try container.resolve()) as DebugViewModel }

        container.register(.singleton) { RealmProvider() }
        container.register(.singleton) { RealmContactRepo(realmProvider: try container.resolve()) as ContactRepo }

        container.register(.singleton) { SymptomRepoImpl() as SymptomRepo }

        return container
    }
}
