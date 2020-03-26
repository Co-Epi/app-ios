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

        return container
    }
}
