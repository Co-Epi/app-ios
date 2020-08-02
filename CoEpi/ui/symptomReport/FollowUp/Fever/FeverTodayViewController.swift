import UIKit

class FeverTodayViewController: UIViewController {
    private let viewModel: FeverTodayViewModel

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var yesButtonLabel: UIButton!
    @IBOutlet var noButtonLabel: UIButton!
    @IBOutlet var skipButtonLabel: UIButton!

    @IBAction func yesButtonAction(_: UIButton) {
        viewModel.onYesTap()
    }

    @IBAction func noButtonAction(_: UIButton) {
        viewModel.onNoTap()
    }

    @IBAction func skipButtonAction(_: UIButton) {
        viewModel.onSkipTap()
    }

    init(viewModel: FeverTodayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = viewModel.title
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            viewModel.onBack()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)

        titleLabel.text = L10n.Ux.Fever.title2
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)

        noButtonLabel.setTitle(L10n.Ux.no, for: .normal)
        yesButtonLabel.setTitle(L10n.Ux.yes, for: .normal)
    }
}
