import UIKit

extension UITableView {

    public func register<T: UITableViewCell>(cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }

    public func dequeue<T: UITableViewCell>(cellClass: T.Type) -> T? {
         return dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier) as? T
     }

     public func dequeue<T: UITableViewCell>(cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
         guard let cell = dequeueReusableCell(
             withIdentifier: cellClass.reuseIdentifier, for: indexPath) as? T else {
                 fatalError(
                    "Cell with id: \(cellClass.reuseIdentifier) for indexPath: \(indexPath) is not: \(T.self)")
            }
         return cell
     }
}
