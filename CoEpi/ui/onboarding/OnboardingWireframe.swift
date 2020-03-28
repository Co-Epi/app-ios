import Foundation
import UIKit
import Dip

class OnboardingWireframe {
    
    private let container: DependencyContainer
    private var onboardingController: UIViewController?
    private var parent: UIViewController?

    init(container: DependencyContainer) {
        self.container = container
    }
    
    func showIfNeeded(parent: UIViewController) {
        
        guard let viewModel: OnboardingViewModel = try? container.resolve() else { return }

        self.parent = parent
        viewModel.delegate = self
        let onboardingController = OnboardingViewController(viewModel: viewModel)
        
        parent.present(onboardingController, animated: true, completion: nil)

        self.onboardingController = onboardingController
        
    }
}

extension OnboardingWireframe : OnboardingViewModelDelegate {
    func onClose() {
        onboardingController?.dismiss(animated: true, completion: nil)
    }
}
