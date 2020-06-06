import Foundation

protocol OnboardingViewModelDelegate: class {
    func onClose()
}

class OnboardingViewModel {
    weak var delegate: OnboardingViewModelDelegate?

    func onCloseClick() {
        delegate?.onClose()
    }
}
