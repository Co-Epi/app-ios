import UIKit

class CoughHowViewController: UIViewController {
    private let viewModel: CoughHowViewModel
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var betterButtonLabel: UIButton!
    @IBOutlet weak var worseButtonLabel: UIButton!
    @IBOutlet weak var sameButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!
    
    @IBAction func betterButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func worseButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func sameButtonAction(_ sender: UIButton) {

    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {

    }
    
    
    init(viewModel: CoughHowViewModel) {
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
        
        titleLabel.text = L10n.Ux.Cough.title3
        subtitleLabel.text = L10n.Ux.Cough.subtitle3
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)
        
        betterButtonLabel.setTitle(L10n.Ux.Cough.better, for: .normal)
        worseButtonLabel.setTitle(L10n.Ux.Cough.worse, for: .normal)
        sameButtonLabel.setTitle(L10n.Ux.Cough.same, for: .normal)
        
        
     }
}
