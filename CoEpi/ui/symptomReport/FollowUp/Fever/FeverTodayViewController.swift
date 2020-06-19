import UIKit

class FeverTodayViewController: UIViewController {
    private let viewModel: FeverTodayViewModel

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var yesButtonLabel: UIButton!
    @IBOutlet weak var noButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!

    @IBAction func yesButtonAction(_ sender: UIButton) {
        viewModel.onYesTap()
    }

    @IBAction func noButtonAction(_ sender: UIButton) {
        viewModel.onNoTap()
    }

    @IBAction func skipButtonAction(_ sender: UIButton) {
        viewModel.onSkipTap()
    }

    init(viewModel: FeverTodayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = viewModel.title
    }

    required init?(coder: NSCoder) {
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
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)

        titleLabel.text = L10n.Ux.Fever.title2
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)

        noButtonLabel.setTitle(L10n.Ux.no, for: .normal)
        yesButtonLabel.setTitle(L10n.Ux.yes, for: .normal)

     }
}
