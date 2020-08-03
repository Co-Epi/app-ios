import Foundation
import UIKit

struct ButtonStyles {
    private init() {}

    static func applySelected(to button: UIButton) {
        button.backgroundColor = .coEpiPurple
        button.setTitleColor(.white, for: .normal)
        ViewStyles.applyShadows(to: button)
        ViewStyles.applyRoundedEnds(to: button)
    }

    static func applyUnselected(to button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.coEpiPurple.cgColor
        button.layer.borderWidth = 1
        ViewStyles.applyShadows(to: button)
        ViewStyles.applyRoundedEnds(to: button)
    }

}

struct ViewStyles {
    static func applyRoundedEnds(to view: UIView) {
        view.layer.cornerRadius = view.frame.height * 0.50
    }

    static func applyShadows(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.35
    }
}
