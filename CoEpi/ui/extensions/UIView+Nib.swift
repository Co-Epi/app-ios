import UIKit

extension UIView {
    // from https://stackoverflow.com/a/36388769
    static func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
