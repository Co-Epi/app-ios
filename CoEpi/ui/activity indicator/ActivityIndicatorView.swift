import UIKit

class ActivityIndicatorView: UIView, CustomView {
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var uiActivityIndicatorView: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        attach()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        attach()
    }

    func startAnimating() {
        uiActivityIndicatorView.startAnimating()
    }
}
