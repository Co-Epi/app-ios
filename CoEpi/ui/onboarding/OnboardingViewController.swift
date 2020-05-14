import UIKit
import SafariServices
import RxSwift
import RxCocoa

class OnboardingViewController: UIViewController {
    private let viewModel: OnboardingViewModel
    
    var state = 0
    
    @IBOutlet weak var introCard: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var howUsedButtonLabel: UIButton!
    @IBOutlet weak var nextButtonLabel: UIButton!
    
    @IBOutlet weak var state1ButtonLabel: UIButton!
    @IBOutlet weak var state2ButtonLabel: UIButton!
    @IBOutlet weak var state3ButtonLabel: UIButton!
    @IBOutlet weak var state4ButtonLabel: UIButton!
    
    
    @IBOutlet weak var joinButtonLabel: UIButton!
    @IBOutlet weak var questionsButtonLabel: UIButton!
    
    
    
    @IBAction func howUsedButtonAction(_ sender: Any) {
        if let url = URL(string: "https://www.coepi.org/privacy/") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        state = state + 1
        updateState(state: state)
    }
    
    @IBAction func state1ButtonAction(_ sender: Any) {
        state = 1
        updateState(state: state)
    }
    
    @IBAction func state2ButtonAction(_ sender: Any) {
        state = 2
        updateState(state: state)
    }
    
    @IBAction func state3ButtonAction(_ sender: Any) {
        state = 3
        updateState(state: state)
    }
    
    @IBAction func state4ButtonAction(_ sender: Any) {
        state = 4
        updateState(state: state)
    }
    
    
    
    @IBAction func joinButtonAction(_ sender: Any) {
        viewModel.onCloseClick()
    }
    
    
    @IBAction func questionsButtonAction(_ sender: Any) {
    }
    
    
    
    
    
    init(viewModel: OnboardingViewModel) {
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
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_purple.png")!)
        
        howUsedButtonLabel.setTitle(L10n.Ux.Onboarding.how, for: .normal)
        nextButtonLabel.setTitle(L10n.Ux.Onboarding.next, for: .normal)
        
        joinButtonLabel.setTitle(L10n.Ux.Onboarding.join, for: .normal)
        questionsButtonLabel.setTitle(L10n.Ux.Onboarding.questions, for: .normal)
        
        state = 1
        updateState(state: state)
        
    }
    
    
    func updateState(state: Int){
        if state == 1{
            introCard.image = UIImage(named: "IntroCard.pdf")
            titleLabel.text = L10n.Ux.Onboarding.title1
            bodyLabel.text = L10n.Ux.Onboarding.body1
            
            state1ButtonLabel.isSelected = true
            state2ButtonLabel.isSelected = false
            state3ButtonLabel.isSelected = false
            state4ButtonLabel.isSelected = false
            
            nextButtonLabel.isHidden = false
            joinButtonLabel.isHidden = true
            questionsButtonLabel.isHidden = true
        }
        else if state == 2{
            introCard.image = UIImage(named: "IntroCard.pdf")
            titleLabel.text = L10n.Ux.Onboarding.title2
            bodyLabel.text = L10n.Ux.Onboarding.body2
            
            state1ButtonLabel.isSelected = false
            state2ButtonLabel.isSelected = true
            state3ButtonLabel.isSelected = false
            state4ButtonLabel.isSelected = false
            
            nextButtonLabel.isHidden = false
            joinButtonLabel.isHidden = true
            questionsButtonLabel.isHidden = true
        }
        else if state == 3{
            introCard.image = UIImage(named: "IntroCard.pdf")
            titleLabel.text = L10n.Ux.Onboarding.title3
            bodyLabel.text = L10n.Ux.Onboarding.body3
            
            state1ButtonLabel.isSelected = false
            state2ButtonLabel.isSelected = false
            state3ButtonLabel.isSelected = true
            state4ButtonLabel.isSelected = false
            
            nextButtonLabel.isHidden = false
            joinButtonLabel.isHidden = true
            questionsButtonLabel.isHidden = true
        }
        else if state == 4{
            introCard.image = UIImage(named: "IntroCardLarge.pdf")
            titleLabel.text = L10n.Ux.Onboarding.title4
            bodyLabel.text = L10n.Ux.Onboarding.body4
            
            state1ButtonLabel.isSelected = false
            state2ButtonLabel.isSelected = false
            state3ButtonLabel.isSelected = false
            state4ButtonLabel.isSelected = true
            
            nextButtonLabel.isHidden = true
            joinButtonLabel.isHidden = false
            questionsButtonLabel.isHidden = false
        }
        else{
            print ("Done")
        }
    }
    
}

private extension OnboardingViewController {}

