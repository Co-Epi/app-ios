import RxSwift
import UIKit

class FeverTempViewController: UIViewController {
    private let viewModel: FeverTempViewModel

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var numberInput: UITextField!

    @IBOutlet var unknownButtonLabel: UIButton!
    @IBOutlet var submitButtonLabel: UIButton!
    @IBOutlet var skipButtonLabel: UIButton!
    @IBOutlet var unitLabel: UILabel!

    private let disposeBag = DisposeBag()

    @IBAction func unknownButtonAction(_: UIButton) {
        viewModel.onUnknownTap()
    }

    @IBAction func submitButtonAction(_: UIButton) {
        viewModel.onSubmitTap()
    }

    @IBAction func skipButtonAction(_: UIButton) {
        viewModel.onSkipTap()
    }

    init(viewModel: FeverTempViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
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
        setupStyle()
        setupText()
        bindInputs()
        bindOutputs()
    }

    private func bindInputs() {
        numberInput.rx.text
            .subscribe(onNext: { [viewModel] text in
                viewModel.onTempChanged(tempStr: text ?? "")
            })
            .disposed(by: disposeBag)

        numberInput.rx.controlEvent(.editingChanged).subscribe(onNext: { [weak self] in
            if let text = self?.numberInput.text {
                self?.numberInput.text = String(text.prefix(5))
            }
        }).disposed(by: disposeBag)
    }

    private func bindOutputs() {
        viewModel.selectedTemperatureUnit
            .drive(unitLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.temperatureText
            .drive(numberInput.rx.text)
            .disposed(by: disposeBag)

        viewModel.setActivityIndicatorVisible
            .drive(view.rx.setActivityIndicatorVisible())
            .disposed(by: disposeBag)
    }

    private func setupStyle() {
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)

        ButtonStyles.applyUnselected(to: unknownButtonLabel)
        ViewStyles.applyRoundedEnds(to: submitButtonLabel)
        ViewStyles.applyShadows(to: submitButtonLabel)
        ViewStyles.applyShadows(to: numberInput)

        viewModel.submitButtonEnabled
            .drive(submitButtonLabel.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.submitButtonEnabled
            .map { $0 ? .coEpiPurple : .lightGray }
            .drive(submitButtonLabel.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    private func setupText() {
        title = viewModel.title
        titleLabel.text = L10n.Ux.Fever.title4
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)
        unknownButtonLabel.setTitle(L10n.Ux.unknown, for: .normal)
        submitButtonLabel.setTitle(L10n.Ux.submit, for: .normal)
    }
}

class CustomTextFieldFeverTemp: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
