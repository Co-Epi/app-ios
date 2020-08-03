import UIKit
import RxSwift

class CoughTypeViewController: UIViewController {
    private let viewModel: CoughTypeViewModel

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var wetTitleButtonLabel: UILabel!
    @IBOutlet var wetDescriptionButtonLabel: UILabel!

    @IBOutlet var dryTitleButtonLabel: UILabel!
    @IBOutlet var dryDescriptionButtonLabel: UILabel!

    @IBOutlet var skipButtonLabel: UIButton!

    private let disposeBag = DisposeBag()

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

        wetTitleButtonLabel.text = L10n.Ux.Cough.titleWet
        wetDescriptionButtonLabel.text = L10n.Ux.Cough.subtitleWet

        dryTitleButtonLabel.text = L10n.Ux.Cough.titleDry
        dryDescriptionButtonLabel.text = L10n.Ux.Cough.subtitleDry

        viewModel.setActivityIndicatorVisible
            .drive(view.rx.setActivityIndicatorVisible())
            .disposed(by: disposeBag)
    }
}
