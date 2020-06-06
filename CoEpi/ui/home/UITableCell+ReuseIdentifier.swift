import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}
