import UIKit

class AlertCell: UITableViewCell {
    var alertView: AlertView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        let view: AlertView = AlertView.fromNib()
        contentView.addSubview(view)
        view.pinAllEdgesToParent()
        alertView = view
    }

    public func setup(alert: AlertViewData,
                      animateRedDot: Bool,
                      onAcknowledged: (AlertViewData) -> Void,
                      onReadDotAnimated: @escaping () -> Void)
    {
        guard let view = alertView else { return }
        view.setup(alert: alert, animateRedDot: animateRedDot, onAcknowledged: onAcknowledged,
                   onReadDotAnimated: onReadDotAnimated)
    }
}

class AlertView: UIView {
    private var alert: AlertViewData?
    private var onAcknowledged: ((AlertViewData) -> Void)?

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var symptomsLabel: UILabel!
    @IBOutlet var borderView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var unreadView: UIView!
    @IBOutlet var repeatedInteractionView: UIView!
    @IBOutlet var repeatedInteractionLabel: UILabel!

    @IBOutlet var labelTrailingToRepeatedViewConstraint: NSLayoutConstraint!
    @IBOutlet var labelTrailingToSuperViewConstraint: NSLayoutConstraint!

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
               animateRedDot: Bool,
               onAcknowledged _: (AlertViewData) -> Void,
               onReadDotAnimated: @escaping () -> Void)
    {
        self.alert = alert

        timeLabel.text = alert.contactTime
        symptomsLabel.text = alert.symptoms
        unreadView.isHidden = !alert.showUnreadDot

        repeatedInteractionView.isHidden = !alert.showRepeatedInteraction
        repeatedInteractionLabel.isHidden = !alert.showRepeatedInteraction
        let highPrio = UILayoutPriority(1000)
        let lowPrio = UILayoutPriority(500)
        if alert.showRepeatedInteraction {
            labelTrailingToRepeatedViewConstraint.priority = highPrio
            labelTrailingToSuperViewConstraint.priority = lowPrio
        } else {
            labelTrailingToRepeatedViewConstraint.priority = lowPrio
            labelTrailingToSuperViewConstraint.priority = highPrio
        }
        repeatedInteractionLabel.text = L10n.Alerts.Overview.Cell.hasRepeatedInteraction

        if animateRedDot {
            unreadView.transform = CGAffineTransform(scaleX: 0, y: 0)
            unreadView.alpha = 0

            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping:
                0.6, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
                    self.unreadView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.unreadView.alpha = 1
                }, completion: { _ in
                    onReadDotAnimated()
                })
        }
    }

    @IBAction func acknowledge(_: UIButton) {
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
