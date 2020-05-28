import UIKit
import RxSwift

class FeverDaysViewController: UIViewController {
    private let viewModel: FeverDaysViewModel
    
    @IBOutlet weak var daysInput: UITextField!
    
    @IBOutlet weak var unknownButtonLabel: UIButton!
    @IBOutlet weak var submitButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!
    
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

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
    
    init(viewModel: FeverDaysViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = viewModel.title
        UINavigationBar.appearance().titleTextAttributes = [.font: Fonts.robotoRegular]
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
        
        titleLabel.text = L10n.Ux.Fever.title1
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
     }
}
