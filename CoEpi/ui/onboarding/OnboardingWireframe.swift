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
        //Schedule presentation of the VC on the main queue (should be executed after HomeViewController is rendered completely, avoiding "Presenting view controllers on detached view controllers is discouraged" warning
        DispatchQueue.main.async(execute: {
            parent.present(onboardingController, animated: true, completion: nil)
        });

        self.onboardingController = onboardingController
        
    }
}

extension OnboardingWireframe : OnboardingViewModelDelegate {
    func onNext() {
        onboardingController?.dismiss(animated: true, completion: nil)
    }
    
    func onClose() {
        onboardingController?.dismiss(animated: true, completion: nil)
    }
}
