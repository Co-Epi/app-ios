import UIKit

class ErrorView: UIView, CustomView {

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        attach()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        attach()
    }

    convenience init(error: String) {
        self.init()
        messageLabel.text = error
    }
}
