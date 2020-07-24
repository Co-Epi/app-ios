import Dip
import Foundation

protocol OnboardingViewModelDelegate: class {
    func onClose()
}
class OnboardingViewModel {
    let title = L10n.Ux.Home.title

    weak var delegate: OnboardingViewModelDelegate?

    func onCloseClick() {
        delegate?.onClose()
    }

}
