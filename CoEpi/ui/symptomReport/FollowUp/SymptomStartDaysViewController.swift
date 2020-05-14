import UIKit

class SymptomStartDaysViewController: UIViewController {
    private let viewModel: SymptomStartDaysViewModel
    
    //labels
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    //buttonLabels
    
    @IBOutlet weak var unknownButtonLabel: UIButton!
    @IBOutlet weak var submitButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!
    
    //day input field
   
    @IBOutlet weak var daysInput: UITextField!
    
    //button actions

    @IBAction func unknownButtonAction(_ sender: Any) {
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
    }
    
    init(viewModel: SymptomStartDaysViewModel) {
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
        
        titleLabel.text = L10n.Ux.Symptomsdays.title
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)
        daysLabel.text = L10n.Ux.days
        
        unknownButtonLabel.setTitle(L10n.Ux.unknown, for: .normal)
        submitButtonLabel.setTitle(L10n.Ux.submit, for: .normal)
        
        
     }
}
