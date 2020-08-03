import UIKit

class RoundButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            layer.backgroundColor =
                isHighlighted ? UIColor.coEpiPurple.cgColor : UIColor.white.cgColor
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        titleLabel?.textAlignment = .center
        layer.borderWidth = 1
        layer.borderColor = UIColor.coEpiPurple.cgColor
        layer.backgroundColor = UIColor.white.cgColor

        ViewStyles.applyShadows(to: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
}
