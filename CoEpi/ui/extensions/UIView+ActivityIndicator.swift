import UIKit

extension UIView {

    func setActivityIndicatorVisible(_ visible: Bool) {
        if visible {
            show()
        } else {
            hide()
        }
    }

    private func show() {
        guard !subviews.contains(where: { $0 is ActivityIndicatorView }) else { return }

        let activityIndicator = ActivityIndicatorView()
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.pinAllEdgesToParent()
        activityIndicator.startAnimating()
        
        activityIndicator.alpha = 0
        UIView.animate(withDuration: fadeAnimDuration) {
            activityIndicator.alpha = 1
        }
    }

    private func hide() {
        guard let activityIndicator = subviews.first(where: { $0 is ActivityIndicatorView }) else { return }

        UIView.animate(withDuration: fadeAnimDuration, animations: {
            activityIndicator.alpha = 0
        }, completion: { _ in
            activityIndicator.removeFromSuperview()
        })
    }
}

private let fadeAnimDuration = 0.25
