import UIKit

class FeverWhereViewController: UIViewController {
    private let viewModel: FeverWhereViewModel
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var mouthButtonLabel: UIButton!
    @IBOutlet weak var earButtonLabel: UIButton!
    @IBOutlet weak var armpitButtonLabel: UIButton!
    @IBOutlet weak var otherButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!
    
    @IBAction func mouthButtonAction(_ sender: UIButton) {
        viewModel.onWhereSelected(spot: .mouth)
    }
    
    @IBAction func earButtonAction(_ sender: UIButton) {
        viewModel.onWhereSelected(spot: .ear)
    }
    
    @IBAction func armpitButtonAction(_ sender: UIButton) {
        viewModel.onWhereSelected(spot: .armpit)
    }
    
    @IBAction func otherButtonAction(_ sender: UIButton) {
        viewModel.onWhereSelected(spot: .armpit)
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        viewModel.onSkipTap()
    }
    
    
    init(viewModel: FeverWhereViewModel) {
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
        
        titleLabel.text = L10n.Ux.Fever.title3
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)
        
        mouthButtonLabel.setTitle(L10n.Ux.Fever.mouth, for: .normal)
        armpitButtonLabel.setTitle(L10n.Ux.Fever.armpit, for: .normal)
        earButtonLabel.setTitle(L10n.Ux.Fever.ear, for: .normal)
        otherButtonLabel.setTitle(L10n.Ux.Fever.other, for: .normal)
     }
}
