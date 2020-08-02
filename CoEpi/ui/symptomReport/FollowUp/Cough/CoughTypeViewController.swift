import UIKit

class CoughTypeViewController: UIViewController {
    private let viewModel: CoughTypeViewModel

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var wetButtonLabel: UIButton!
    @IBOutlet var dryButtonLabel: UIButton!
    @IBOutlet var skipButtonLabel: UIButton!

    @IBAction func wetButtonAction(_: UIButton) {
        viewModel.onTapWet()
    }

    @IBAction func dryButtonAction(_: UIButton) {
        viewModel.onTapDry()
    }

    @IBAction func skipButtonAction(_: UIButton) {
        viewModel.onSkipTap()
    }

    init(viewModel: CoughTypeViewModel) {
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

        titleLabel.text = L10n.Ux.Cough.title1
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)

        let bold24 = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        let system11 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)]

        let textWet = NSMutableAttributedString(
            string: L10n.Ux.Cough.titleWet,
            attributes: bold24
        )
        textWet.append(NSMutableAttributedString(
            string: L10n.Ux.Cough.subtitleWet,
            attributes: system11
        ))
        wetButtonLabel.setAttributedTitle(textWet, for: .normal)

        let textDry = NSMutableAttributedString(
            string: L10n.Ux.Cough.titleDry,
            attributes: bold24
        )
        textDry.append(NSMutableAttributedString(
            string: L10n.Ux.Cough.subtitleDry,
            attributes: system11
        ))
        dryButtonLabel.setAttributedTitle(textDry, for: .normal)
    }
}
