import Foundation
import SwiftUI
import UIKit

extension UIViewController {
    func setRootSwiftUIView<T: View>(view: T) {
        let host = UIHostingController(rootView: view)
        guard let hostView = host.view else { return }
        hostView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(hostView)
        // Space beyond safe areas should have default color
        self.view.backgroundColor = UIColor.white

        hostView.pinAllEdgesToParent(useTopSafeArea: true, useBottomSafeArea: false)
    }
}
