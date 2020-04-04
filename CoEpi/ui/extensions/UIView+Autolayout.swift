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

    func pinTopToParent() {
        guard let superview = requireSuperview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
    }

    func pinBottomToParent() {
        guard let superview = requireSuperview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
    }

    func pinAllEdgesToParent() {
        pinLeadingToParent()
        pinTrailingToParent()
        pinTopToParent()
        pinBottomToParent()
    }

    private var requireSuperview: UIView? {
         guard let superview = self.superview else {
            print("Error! `superview` was nil. Ensure view is in the hierarchy.")
            return nil
        }
        return superview
    }
}

