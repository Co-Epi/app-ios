import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIView {
    func setActivityIndicatorVisible() -> Binder<Bool> {
        return Binder(base) { view, visible in
            view.setActivityIndicatorVisible(visible)
        }
    }
}
