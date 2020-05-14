import UIKit

class FeverWhereViewControllerOther: UIViewController {
    private let viewModel: FeverWhereViewModelOther
    //labels
    @IBOutlet weak var titleLabel: UILabel!
    
    //text input
    @IBOutlet weak var textInput: UITextField!
    
    //button labels
    @IBOutlet weak var skipButtonLabel: UIButton!
    @IBOutlet weak var submitButtonLabel: UIButton!
    
    //button actions
    @IBAction func skipButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func submitButtonAction(_ sender: UIButton) {

    }
    
    
    init(viewModel: FeverWhereViewModelOther) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = viewModel.title
        UINavigationBar.appearance().titleTextAttributes = [.font: Fonts.robotoRegular]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)
        
        titleLabel.text = L10n.Ux.Fever.title3
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)

        submitButtonLabel.setTitle(L10n.Ux.submit, for: .normal)
        
     }
}
