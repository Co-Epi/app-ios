import UIKit

class AlertCell: UITableViewCell {
    public var onAcknowledged: ((AlertViewData) ->())?

    private var alert: AlertViewData?
    private var alertView: AlertView?

    public func setAlert(alert: AlertViewData) {
        self.alert = alert
        setupUI(alert: alert)
    }
    
    private func setupUI(alert: AlertViewData) {
        let view: AlertView = AlertView.fromNib()

        view.exposureTypeLabel.text = alert.symptoms
        view.timeLabel.text = alert.time
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
