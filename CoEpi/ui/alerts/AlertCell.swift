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
        view.onAcknowledged = { [weak self] in
            self?.onAcknowledged?(alert)
        }

        contentView.addSubview(view)
    }
}

class AlertView: UIView {
    public var onAcknowledged: (() ->())?

    @IBAction func acknowledge(_ sender: UIButton) {
        onAcknowledged?()
    }
}
