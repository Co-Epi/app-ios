import UIKit

class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        self.title = self.viewModel.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func quizTapped(_ sender: Any) {
        viewModel.quizTapped()
    }
    @IBAction func debugTapped(_: UIButton) {
        viewModel.debugTapped()
    }
}
