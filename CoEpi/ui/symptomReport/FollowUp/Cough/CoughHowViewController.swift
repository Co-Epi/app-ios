import UIKit
import RxSwift

class CoughHowViewController: UIViewController {
    private let viewModel: CoughHowViewModel

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    @IBOutlet var betterButtonLabel: UIButton!
    @IBOutlet var worseButtonLabel: UIButton!
    @IBOutlet var sameButtonLabel: UIButton!
    @IBOutlet var skipButtonLabel: UIButton!

    private let disposeBag = DisposeBag()

    @IBAction func betterButtonAction(_: UIButton) {
        viewModel.onStatusSelected(status: .betterAndWorseThroughDay)
    }

    @IBAction func worseButtonAction(_: UIButton) {
        viewModel.onStatusSelected(status: .worseWhenOutside)
    }

    @IBAction func sameButtonAction(_: UIButton) {
        viewModel.onStatusSelected(status: .sameOrSteadilyWorse)
    }

    @IBAction func skipButtonAction(_: UIButton) {
        viewModel.onSkipTap()
    }

    init(viewModel: CoughHowViewModel) {
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

        titleLabel.text = L10n.Ux.Cough.title3
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)

        ButtonStyles.applyUnselected(to: betterButtonLabel)
        ButtonStyles.applyUnselected(to: worseButtonLabel)
        ButtonStyles.applyUnselected(to: sameButtonLabel)

        betterButtonLabel.addTarget(self, action: #selector(onTouchDown(to:)), for: .touchDown)
        betterButtonLabel.addTarget(self, action: #selector(onTouchUp), for: .touchUpInside)
        betterButtonLabel.addTarget(self, action: #selector(onTouchUp(to:)), for: .touchUpOutside)

        worseButtonLabel.addTarget(self, action: #selector(onTouchDown(to:)), for: .touchDown)
        worseButtonLabel.addTarget(self, action: #selector(onTouchUp), for: .touchUpInside)
        worseButtonLabel.addTarget(self, action: #selector(onTouchUp(to:)), for: .touchUpOutside)

        sameButtonLabel.addTarget(self, action: #selector(onTouchDown(to:)), for: .touchDown)
        sameButtonLabel.addTarget(self, action: #selector(onTouchUp), for: .touchUpInside)
        sameButtonLabel.addTarget(self, action: #selector(onTouchUp(to:)), for: .touchUpOutside)

        betterButtonLabel.setTitle(L10n.Ux.Cough.better, for: .normal)
        betterButtonLabel.titleLabel?.textAlignment = .center
        betterButtonLabel.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        worseButtonLabel.setTitle(L10n.Ux.Cough.worse, for: .normal)
        worseButtonLabel.titleLabel?.textAlignment = .center
        worseButtonLabel.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        sameButtonLabel.setTitle(L10n.Ux.Cough.same, for: .normal)
        sameButtonLabel.titleLabel?.textAlignment = .center
        sameButtonLabel.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

        viewModel.setActivityIndicatorVisible
            .drive(view.rx.setActivityIndicatorVisible())
            .disposed(by: disposeBag)
    }

    @objc func onTouchDown(to button: UIButton) {
        ButtonStyles.applySelected(to: button)
    }

    @objc func onTouchUp(to button: UIButton) {
        ButtonStyles.applyUnselected(to: button)
    }
}
