import Foundation
import UIKit

extension UIView {
    func pinLeadingToParent() {
        guard let superview = requireSuperview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
    }

    func pinTrailingToParent() {
        guard let superview = requireSuperview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }

    func pinTopToParent(useSafeArea: Bool) {
        guard let superview = requireSuperview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(
            equalTo: useSafeArea ?
                superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor,
            constant: 0.0
        ).isActive = true
    }

    func pinBottomToParent(useSafeArea: Bool) {
        guard let superview = requireSuperview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(
            equalTo: useSafeArea ?
                superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor,
            constant: 0.0
        ).isActive = true
    }

    func pinAllEdgesToParent(useTopSafeArea: Bool = false,
                             useBottomSafeArea: Bool = false)
    {
        pinLeadingToParent()
        pinTrailingToParent()
        pinTopToParent(useSafeArea: useTopSafeArea)
        pinBottomToParent(useSafeArea: useBottomSafeArea)
    }

    private var requireSuperview: UIView? {
        guard let superview = self.superview else {
            print("Error! `superview` was nil. Ensure view is in the hierarchy.")
            return nil
        }
        return superview
    }
}
