import UIKit

class GradientView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0, 1]
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
