import UIKit

class AlertCell: UITableViewCell {
    public var onAcknowledged: ((Alert) ->())?

    private var alert: Alert?
    private var alertView: AlertView?

    public func setAlert(alert: Alert) {
        self.alert = alert
        setupUI(alert: alert)
    }
    
    private func setupUI(alert: Alert) {
        let view: AlertView = AlertView.fromNib()

        view.exposureTypeLabel.text = alert.exposure
        view.timeLabel.text = "\(Date(timeIntervalSince1970: TimeInterval(alert.report.report.timestamp)))"
        view.onAcknowledged = { [weak self] in
            self?.onAcknowledged?(alert)
        }

        contentView.addSubview(view)
        view.pinAllEdgesToParent()
    }
}

class AlertView: UIView {
    public var onAcknowledged: (() ->())?

    @IBOutlet weak var exposureTypeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBAction func acknowledge(_ sender: UIButton) {
        onAcknowledged?()
    }
}
