import UIKit

class CoughTypeViewController: UIViewController {
    private let viewModel: CoughTypeViewModel

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var wetButtonLabel: UIButton!
    @IBOutlet weak var dryButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!

    @IBAction func wetButtonAction(_ sender: UIButton) {
        viewModel.onTapWet()
    }

    @IBAction func dryButtonAction(_ sender: UIButton) {
        viewModel.onTapDry()
     }

    @IBAction func skipButtonAction(_ sender: UIButton) {
        viewModel.onSkipTap()
     }

    init(viewModel: CoughTypeViewModel) {
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
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)

        titleLabel.text = L10n.Ux.Cough.title1
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)

        let bold24 = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        let system11 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)]

        let titleWet = L10n.Ux.Cough.titleWet
        let subtitleWet = L10n.Ux.Cough.subtitleWet
        let textWet = NSMutableAttributedString(string: titleWet, attributes: bold24)
        textWet.append(NSMutableAttributedString(string: subtitleWet, attributes: system11))
        wetButtonLabel.setAttributedTitle(textWet, for: .normal)
        wetButtonLabel.titleLabel?.textAlignment = .center

        let titleDry = L10n.Ux.Cough.titleDry
        let subtitleDry = L10n.Ux.Cough.subtitleDry
        let textDry = NSMutableAttributedString(string: titleDry, attributes: bold24)
        textDry.append(NSMutableAttributedString(string: subtitleDry, attributes: system11))
        dryButtonLabel.setAttributedTitle(textDry, for: .normal)
        dryButtonLabel.titleLabel?.textAlignment = .center
     }
}
