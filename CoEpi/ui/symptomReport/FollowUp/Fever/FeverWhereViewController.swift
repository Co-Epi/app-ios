import UIKit
import RxSwift

class FeverWhereViewController: UIViewController {
    private let viewModel: FeverWhereViewModel

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var mouthButtonLabel: UIButton!
    @IBOutlet var earButtonLabel: UIButton!
    @IBOutlet var armpitButtonLabel: UIButton!
    @IBOutlet var otherButtonLabel: UIButton!
    @IBOutlet var skipButtonLabel: UIButton!

    private let disposeBag = DisposeBag()

    @IBAction func mouthButtonAction(_: UIButton) {
        viewModel.onWhereSelected(spot: .mouth)
    }

    @IBAction func earButtonAction(_: UIButton) {
        viewModel.onWhereSelected(spot: .ear)
    }

    @IBAction func armpitButtonAction(_: UIButton) {
        viewModel.onWhereSelected(spot: .armpit)
    }

    @IBAction func otherButtonAction(_: UIButton) {
        viewModel.onWhereSelected(spot: .other)
    }

    @IBAction func skipButtonAction(_: UIButton) {
        viewModel.onSkipTap()
    }

    init(viewModel: FeverWhereViewModel) {
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

        titleLabel.text = L10n.Ux.Fever.title3
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)

        mouthButtonLabel.setTitle(L10n.Ux.Fever.mouth, for: .normal)
        armpitButtonLabel.setTitle(L10n.Ux.Fever.armpit, for: .normal)
        earButtonLabel.setTitle(L10n.Ux.Fever.ear, for: .normal)
        otherButtonLabel.setTitle(L10n.Ux.Fever.other, for: .normal)

        viewModel.setActivityIndicatorVisible
            .drive(view.rx.setActivityIndicatorVisible())
            .disposed(by: disposeBag)
    }
}
