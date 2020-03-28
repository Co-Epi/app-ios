import UIKit

// TODO reusable styles. Not with subclassing.

class OnboardingButton: UIButton {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        backgroundColor = Theme.color.coepiPrimaryButton
        layer.cornerRadius = 5
        contentEdgeInsets = UIEdgeInsets(top: 20,
                                         left: 40,
                                         bottom: 20,
                                         right: 40)
        
        setTitleColor(.white, for: .normal)
        
    }
    
}
