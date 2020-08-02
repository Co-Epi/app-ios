import UIKit

class ErrorView: UIView, CustomView {
    @IBOutlet var rootView: UIView!
    @IBOutlet var messageLabel: UILabel!

    override init(frame _: CGRect) {
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
