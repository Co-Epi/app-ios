import UIKit

class AlertCell: UITableViewCell {
    var alertView: AlertView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
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

    public func setup(alert: AlertViewData,
                      onAcknowledged: (AlertViewData) -> Void,
                      onReadDotAnimated: () -> Void) {
        guard let view = alertView else { return }
        view.setup(alert: alert, onAcknowledged: onAcknowledged,
                   onReadDotAnimated: onReadDotAnimated)
    }
}

class AlertView: UIView {
    private var alert: AlertViewData?
    private var onAcknowledged: ((AlertViewData) -> Void)?

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var symptomsLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var unreadView: UIView!
    @IBOutlet weak var repeatedInteractionView: UIView!
    @IBOutlet weak var repeatedInteractionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        borderView.layer.cornerRadius = 15

        containerView.layer.cornerRadius = 15
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowRadius = 1
        containerView.layer.shadowOpacity = 0.2

        unreadView.layer.cornerRadius = 11
    }

    func setup(alert: AlertViewData,
               onAcknowledged: (AlertViewData) -> Void,
               onReadDotAnimated: () -> Void) {
        self.alert = alert

        timeLabel.text = alert.contactTime
        symptomsLabel.text = alert.symptoms
        unreadView.isHidden = !alert.showUnreadDot
        repeatedInteractionView.isHidden = !alert.showRepeatedInteraction

        repeatedInteractionLabel.text = L10n.Alerts.Overview.Cell.hasRepeatedInteraction

        if alert.animateUnreadDot {
            unreadView.transform = CGAffineTransform(scaleX: 0, y: 0)
            unreadView.alpha = 0
            onReadDotAnimated()
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping:
                0.6, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                    self.unreadView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.unreadView.alpha = 1
                }, completion: nil)
        }
    }

    @IBAction func acknowledge(_ sender: UIButton) {
        guard let alert = alert else {
            log.e("Alert must be set in setup")
            return
        }
        onAcknowledged?(alert)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        containerView.backgroundColor = .coEpiLightGray
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        containerView.backgroundColor = .white
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        containerView.backgroundColor = .white
    }
}
