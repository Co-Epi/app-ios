import UIKit

class AlertCell: UITableViewCell {
    public var onAcknowledged: ((AlertViewData) ->())?

    private var alert: AlertViewData?
    var alertView: AlertView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        let view: AlertView = AlertView.fromNib()
        contentView.addSubview(view)
        view.pinAllEdgesToParent()
        self.alertView = view
    }

    public func setAlert(alert: AlertViewData) {
        self.alert = alert

        guard let view = alertView else { return }
        view.timeLabel.text = alert.contactTime
        view.symptomsLabel.text = alert.symptoms
        view.onAcknowledged = { [weak self] in
            self?.onAcknowledged?(alert)
        }
    }
}

class AlertView: UIView {
    public var onAcknowledged: (() ->())?

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var symptomsLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 15
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowRadius = 1
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 0.5
        containerView.layer.shadowOpacity = 0.2
    }

    @IBAction func acknowledge(_ sender: UIButton) {
        onAcknowledged?()
    }
}
