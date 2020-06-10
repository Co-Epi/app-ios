import UIKit
import RxSwift

class FeverTempViewController: UIViewController {
    private let viewModel: FeverTempViewModel

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var numberInput: UITextField!

    @IBOutlet weak var unknownButtonLabel: UIButton!
    @IBOutlet weak var submitButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!
    @IBOutlet weak var scaleButtonLabel: UIButton!

    private let disposeBag = DisposeBag()

    @IBAction func unknownButtonAction(_ sender: UIButton) {
        viewModel.onUnknownTap()
    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {
        viewModel.onSubmitTap()
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        viewModel.onSkipTap()
    }
    
    @IBAction func scaleButtonAction(_ sender: UIButton) {
        viewModel.onTemperatureUnitPress()
    }
    

    init(viewModel: FeverTempViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
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
            .map { toButtonText(unit: $0) }
            .drive(scaleButtonLabel.rx.attributedTitle())
            .disposed(by: disposeBag)

        viewModel.temperatureText
            .drive(numberInput.rx.text)
            .disposed(by: disposeBag)
    }

    private func setupStyle() {
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)
        scaleButtonLabel.tintColor = .black
        
        ButtonStyles.applyUnselected(to: unknownButtonLabel)
        ButtonStyles.applyRoundedEnds(to: submitButtonLabel)
        ButtonStyles.applyShadows(to: submitButtonLabel)
        
        viewModel.submitButtonEnabled
            .drive(submitButtonLabel.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.submitButtonEnabled
            .map{ $0 ? .systemBlue : .lightGray }
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

private func toButtonText(unit: TemperatureUnit) -> NSAttributedString {
    let selectedSize: CGFloat = 40
    let unSelectedSize: CGFloat = 35

    let (celsiusSize, fahrenheitSize): (CGFloat, CGFloat) = {
        switch unit {
        case .celsius: return (selectedSize, unSelectedSize)
        case .fahrenheit: return (unSelectedSize, selectedSize)
        }
    }()

    return attrString(string: L10n.Ux.Fever.f, size: fahrenheitSize) + attrString(string: "/", size: 40)
        + attrString(string: L10n.Ux.Fever.c, size: celsiusSize)
}

private func attrString(string: String, size: CGFloat) -> NSAttributedString {
    NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: size)])
}

class CustomTextFieldFeverTemp: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
