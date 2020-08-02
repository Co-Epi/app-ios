import SafariServices
import UIKit

// TODO: refactor this file

class OnboardingViewController: UIViewController {
    private let viewModel: OnboardingViewModel

    var state = 0

    @IBOutlet var introCard: UIView!
    @IBOutlet var introCardHeight: NSLayoutConstraint!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!

    @IBOutlet var howUsedButtonLabel: UIButton!
    @IBOutlet var nextButtonLabel: UIButton!

    @IBOutlet var state1ButtonLabel: UIButton!
    @IBOutlet var state2ButtonLabel: UIButton!
    @IBOutlet var state3ButtonLabel: UIButton!
    @IBOutlet var state4ButtonLabel: UIButton!

    @IBOutlet var joinButtonLabel: UIButton!

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet var titleSubtitleConstraint: NSLayoutConstraint!
    @IBOutlet var imageViewBottomConstraint: NSLayoutConstraint!

    @IBAction func howUsedButtonAction(_: Any) {
        if let url = URL(string: "https://www.coepi.org/privacy/") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = false

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }

    @IBAction func nextButtonAction(_: Any) {
        state += 1
        updateState(state: state)
    }

    @IBAction func state1ButtonAction(_: Any) {
        state = 1
        updateState(state: state)
    }

    @IBAction func state2ButtonAction(_: Any) {
        state = 2
        updateState(state: state)
    }

    @IBAction func state3ButtonAction(_: Any) {
        state = 3
        updateState(state: state)
    }

    @IBAction func state4ButtonAction(_: Any) {
        state = 4
        updateState(state: state)
    }

    @IBAction func joinButtonAction(_: Any) {
        viewModel.onCloseClick()
    }

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
        title = viewModel.title
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_purple.png")!)

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
