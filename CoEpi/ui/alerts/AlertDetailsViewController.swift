import UIKit

class AlertDetailsViewController: UIViewController {
    private let viewModel: AlertDetailsViewModel

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contactTimeLabel: UILabel!
    @IBOutlet weak var symptomsTitleLabel: UILabel!
    @IBOutlet weak var reportedOnLabel: UILabel!
    @IBOutlet weak var symptomsLabel: UILabel!

    init(viewModel: AlertDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = viewModel.viewData.title
        contactTimeLabel.text = viewModel.viewData.contactTime
        symptomsTitleLabel.text = L10n.Alerts.Details.Label.symptomsTitle
        reportedOnLabel.text = viewModel.viewData.reportTime
        symptomsLabel.text = viewModel.viewData.symptoms
    }
}
