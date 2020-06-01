import UIKit
import SafariServices

class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    
    @IBOutlet weak var redCircle: UIImageView!
    
    @IBOutlet weak var reportButtonLabel: UIButton!
    @IBOutlet weak var alertButtonLabel: UIButton!
    @IBOutlet weak var howDataUsedLabel: UIButton!
    
    @IBAction func reportButtonAction(_ sender: Any) {
        viewModel.quizTapped()
    }
    
    @IBAction func alertButtonAction(_ sender: Any) {
        viewModel.seeAlertsTapped()
    }
    
    @IBAction func howDataUsedButton(_ sender: Any) {
        if let url = URL(string: "https://www.coepi.org/privacy/") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildLabel: UILabel!
    @IBOutlet weak var debugButton: UIButton!
    
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        self.title = self.viewModel.title
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: Fonts.robotoRegular]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func debugTapped(_: UIButton) {
        viewModel.debugTapped()
    }
    
    @objc func share(sender: UIView) {
        Sharer().share(viewController: self, sourceView: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_purple.png")!)
        
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = 1.07
        
        let share = UIBarButtonItem(title: L10n.Home.share, style: .plain, target: self, action: #selector(share(sender:)))
        share.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = share
        
        //setup button labels
        
        reportButtonLabel.layer.cornerRadius = 15
        reportButtonLabel.layer.shadowColor = UIColor.black.cgColor
        reportButtonLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        reportButtonLabel.layer.shadowRadius = 4
        reportButtonLabel.layer.shadowOpacity = 1.0
        
        alertButtonLabel.layer.cornerRadius = 15
        alertButtonLabel.layer.shadowColor = UIColor.black.cgColor
        alertButtonLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
        alertButtonLabel.layer.shadowRadius = 4
        alertButtonLabel.layer.shadowOpacity = 1.0
        
        howDataUsedLabel.setTitle(L10n.Ux.Home.how, for: .normal)
        
        let attributedTextReport = NSMutableAttributedString(string: L10n.Ux.Home.report1, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)])
        attributedTextReport.append(NSMutableAttributedString(string: L10n.Ux.Home.report2, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
        reportButtonLabel.setAttributedTitle(attributedTextReport, for: .normal)
        
        let tempNumbnerOfNotifications = 0 //temp for testing will need to be replaced with checking if new alerts are available
        
        if tempNumbnerOfNotifications == 0{
            redCircle.isHidden = true
            let attributedTextAlert = NSMutableAttributedString(string: L10n.Ux.Home.alerts1, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)])
            attributedTextAlert.append(NSMutableAttributedString(string: L10n.Ux.Home.alerts2, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
            alertButtonLabel.setAttributedTitle(attributedTextAlert, for: .normal)
        }
        else{
            redCircle.isHidden = false
            let attributedTextAlert = NSMutableAttributedString(string: L10n.Ux.Home.detected, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.red])
            attributedTextAlert.append(NSMutableAttributedString(string: L10n.Ux.Home.alerts1, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]))
            
            attributedTextAlert.append(NSMutableAttributedString(string: L10n.Ux.Home.alerts2, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]))
            
            alertButtonLabel.setAttributedTitle(attributedTextAlert, for: .normal)
        }
        
        //debug
        versionLabel.text = getVersionNumber()
        buildLabel.text = getBuildNumber()
        debugButton.setTitle(L10n.Home.Footer.debug, for: .normal)
    }
    
    private func getVersionNumber() -> String{
        
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
         else{
            fatalError("Failed to read bundle version")
        }
        print("Version : \(version)");
        return "\(L10n.Home.Footer.version): \(version)"
    }
    
    private func getBuildNumber() -> String {
        guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            fatalError("Failed to read build number")
        }
        print("Build : \(build)")
        return "\(L10n.Home.Footer.build): \(build)"
    }
}
