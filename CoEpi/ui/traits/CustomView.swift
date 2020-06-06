import UIKit

protocol CustomView {
    var rootView: UIView! { get }

    func attach()
}


extension CustomView where Self: UIView {

    func attach() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        addSubview(rootView)
        rootView.frame = bounds
        rootView.pinAllEdgesToParent()
    }
}
