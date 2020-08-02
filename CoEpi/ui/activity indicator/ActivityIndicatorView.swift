import UIKit

class ActivityIndicatorView: UIView, CustomView {
    @IBOutlet var rootView: UIView!
    @IBOutlet var uiActivityIndicatorView: UIActivityIndicatorView!

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
