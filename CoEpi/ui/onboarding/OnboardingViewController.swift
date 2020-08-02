import UIKit
import SafariServices

// TODO refactor this file

class OnboardingViewController: UIViewController {
    private let viewModel: OnboardingViewModel

    var state = 0

    @IBOutlet weak var introCard: UIView!
    @IBOutlet weak var introCardHeight: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    @IBOutlet weak var howUsedButtonLabel: UIButton!
    @IBOutlet weak var nextButtonLabel: UIButton!

    @IBOutlet weak var state1ButtonLabel: UIButton!
    @IBOutlet weak var state2ButtonLabel: UIButton!
    @IBOutlet weak var state3ButtonLabel: UIButton!
    @IBOutlet weak var state4ButtonLabel: UIButton!

    @IBOutlet weak var joinButtonLabel: UIButton!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleSubtitleConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!

    @IBAction func howUsedButtonAction(_ sender: Any) {
        if let url = URL(string: "https://www.coepi.org/privacy/") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }

    @IBAction func nextButtonAction(_ sender: Any) {
        state += 1
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

    init(viewModel: OnboardingViewModel) {
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

        howUsedButtonLabel.setTitle(L10n.Ux.Onboarding.how, for: .normal)
        nextButtonLabel.setTitle(L10n.Ux.Onboarding.next, for: .normal)

        joinButtonLabel.setTitle(L10n.Ux.Onboarding.join, for: .normal)

        ButtonStyles.applyUnselected(to: joinButtonLabel)
        ButtonStyles.applySelected(to: nextButtonLabel)

        state = 1

        updateState(state: state)
    }

    func updateState(state: Int) {
        if state == 1 {
            introCard.layer.cornerRadius = 40
            introCardHeight.constant = 384

            titleLabel.text = L10n.Ux.Onboarding.title1
            bodyLabel.text = L10n.Ux.Onboarding.body1

            state1ButtonLabel.isSelected = true
            state2ButtonLabel.isSelected = false
            state3ButtonLabel.isSelected = false
            state4ButtonLabel.isSelected = false

            nextButtonLabel.isHidden = false
            joinButtonLabel.isHidden = true

            imageView.image = #imageLiteral(resourceName: "slide1")
            imageViewBottomConstraint.constant = -40
            titleTopConstraint.constant = 34
            titleSubtitleConstraint.constant = 20

        } else if state == 2 {
            introCard.layer.cornerRadius = 40
            introCardHeight.constant = 384
            titleLabel.text = L10n.Ux.Onboarding.title2
            bodyLabel.text = L10n.Ux.Onboarding.body2

            state1ButtonLabel.isSelected = false
            state2ButtonLabel.isSelected = true
            state3ButtonLabel.isSelected = false
            state4ButtonLabel.isSelected = false

            nextButtonLabel.isHidden = false
            joinButtonLabel.isHidden = true

            imageView.image = #imageLiteral(resourceName: "slide2")
            imageViewBottomConstraint.constant = -40
            titleTopConstraint.constant = 34
            titleSubtitleConstraint.constant = 20

        } else if state == 3 {
            introCard.layer.cornerRadius = 40
            introCardHeight.constant = 384
            titleLabel.text = L10n.Ux.Onboarding.title3
            bodyLabel.text = L10n.Ux.Onboarding.body3

            state1ButtonLabel.isSelected = false
            state2ButtonLabel.isSelected = false
            state3ButtonLabel.isSelected = true
            state4ButtonLabel.isSelected = false

            nextButtonLabel.isHidden = false
            joinButtonLabel.isHidden = true

            // TODO: hack: ask for correctly cut images
            let imageBottom: CGFloat =
                UIScreen.main.bounds.height > 800 ? -135 : -100

            imageView.image = #imageLiteral(resourceName: "slide3")
            imageViewBottomConstraint.constant = imageBottom
            titleTopConstraint.constant = 34
            titleSubtitleConstraint.constant = 20

        } else if state == 4 {
            introCard.layer.cornerRadius = 40
            introCardHeight.constant = 549

            titleLabel.text = L10n.Ux.Onboarding.title4
            bodyLabel.text = L10n.Ux.Onboarding.body4

            state1ButtonLabel.isSelected = false
            state2ButtonLabel.isSelected = false
            state3ButtonLabel.isSelected = false
            state4ButtonLabel.isSelected = true

            nextButtonLabel.isHidden = true
            joinButtonLabel.isHidden = false
            titleTopConstraint.constant = 65
            titleSubtitleConstraint.constant = 45

            imageView.image = nil
            imageViewBottomConstraint.constant = 0

        } else {
            print("Done")
        }
    }
}

private extension OnboardingViewController {}

class StepperView: UIButton {
    override var isSelected: Bool {
        didSet {
            layer.backgroundColor = isSelected ?
                UIColor.coEpiPurple.cgColor : UIColor(hex: "d6d6d6").cgColor
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}
