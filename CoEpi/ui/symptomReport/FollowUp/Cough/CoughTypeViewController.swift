import UIKit

class CoughTypeViewController: UIViewController {
    private let viewModel: CoughTypeViewModel
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var wetButtonLabel: UIButton!
    @IBOutlet weak var dryButtonLabel: UIButton!
    @IBOutlet weak var skipButtonLabel: UIButton!
    
    @IBAction func wetButtonAction(_ sender: UIButton) {
        viewModel.onTapWet()
    }
    
    @IBAction func dryButtonAction(_ sender: UIButton) {
        viewModel.onTapDry()
     }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        viewModel.onSkipTap()
     }
    
    init(viewModel: CoughTypeViewModel) {
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
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)
        
        titleLabel.text = L10n.Ux.Cough.title1
        skipButtonLabel.setTitle(L10n.Ux.skip, for: .normal)
        
        let attributedTextWet = NSMutableAttributedString(string: L10n.Ux.Cough.titleWet, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)])
        attributedTextWet.append(NSMutableAttributedString(string: L10n.Ux.Cough.subtitleWet, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)]))
        wetButtonLabel.setAttributedTitle(attributedTextWet, for: .normal)
        wetButtonLabel.titleLabel?.textAlignment = .center
        
        let attributedTextDry = NSMutableAttributedString(string: L10n.Ux.Cough.titleDry, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)])
        attributedTextDry.append(NSMutableAttributedString(string: L10n.Ux.Cough.subtitleDry, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)]))
        dryButtonLabel.setAttributedTitle(attributedTextDry, for: .normal)
        dryButtonLabel.titleLabel?.textAlignment = .center
     }
}
