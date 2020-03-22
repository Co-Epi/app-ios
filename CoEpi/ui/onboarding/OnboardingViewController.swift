import UIKit

class OnboardingViewController: UIViewController {

    private let viewModel: OnboardingViewModel

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func onCloseClick(_ sender: UIButton) {
        viewModel.onCloseClick()
    }
}
