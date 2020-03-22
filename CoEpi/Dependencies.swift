import Foundation
import Dip

class Dependencies {

    func createContainer() -> DependencyContainer {
        let container = DependencyContainer()
        
        container.register(.unique) { OnboardingWireframe(container: container) }
        container.register(.unique) { OnboardingViewModel() }

        return container
    }
}
