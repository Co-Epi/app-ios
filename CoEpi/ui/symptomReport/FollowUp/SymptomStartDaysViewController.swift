import UIKit
import RxSwift

class SymptomStartDaysViewController: UIViewController {
    private let viewModel: SymptomStartDaysViewModel
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    
    @IBOutlet weak var unknownButtonLabel: UIButton!
    @IBOutlet weak var submitButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!

    @IBOutlet weak var daysInput: UITextField!

    private let disposeBag = DisposeBag()

    @IBAction func unknownButtonAction(_ sender: Any) {
        viewModel.onUnknownTap()
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        viewModel.onSubmitTap()
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
        viewModel.onSkipTap()
    }
    
    init(viewModel: SymptomStartDaysViewModel) {
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
        
        titleLabel.text = L10n.Ux.Symptomsdays.title
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)
        daysLabel.text = L10n.Ux.days
        
        unknownButtonLabel.setTitle(L10n.Ux.unknown, for: .normal)
        submitButtonLabel.setTitle(L10n.Ux.submit, for: .normal)

        daysInput.rx.text
            .distinctUntilChanged()
            .subscribe(onNext: { [viewModel] text in
                viewModel.onDaysChanged(daysStr: text ?? "")
            })
            .disposed(by: disposeBag)

        viewModel.setActivityIndicatorVisible
            .drive(view.rx.setActivityIndicatorVisible())
            .disposed(by: disposeBag)
     }
}
