import UIKit

class ThankYouViewController: UIViewController {
    private let viewModel: ThankYouViewModel
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var moreButtonLabel: UIButton!
    @IBOutlet weak var viewExposuresButtonLabel: UIButton!
    @IBOutlet weak var homeButtonLabel: UIButton!

    @IBAction func moreButtonAction(_ sender: UIButton) {
        viewModel.onCheckInClick()
    }
    
    @IBAction func viewExposuresButtonAction(_ sender: UIButton) {
        viewModel.onSeeAlertsClick()
     }
    
    @IBAction func homeButtonAction(_ sender: UIButton) {
        viewModel.onCloseClick()
     }
    
    init(viewModel: ThankYouViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = viewModel.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_purple.png")!)
        
        titleLabel.text = L10n.Ux.Thankyou.title
        moreButtonLabel.setTitle(L10n.Ux.Thankyou.more, for: .normal)
        viewExposuresButtonLabel.setTitle(L10n.Ux.Thankyou.viewExposures, for: .normal)
        homeButtonLabel.setTitle(L10n.Ux.Thankyou.home, for: .normal)
        
        ButtonStyles.applyUnselected(to: moreButtonLabel)
        ButtonStyles.applyUnselected(to: viewExposuresButtonLabel)
        ButtonStyles.applyUnselected(to: homeButtonLabel)

        navigationItem.hidesBackButton = true
     }
}
