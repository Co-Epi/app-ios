import Foundation
import UIKit

struct ButtonStyles{
    
    private init(){}

    static func applySelected(to button : UIButton){
        button.backgroundColor = .coEpiPurple
        button.setTitleColor(.white, for:.normal)
        applyShadows(to: button)
        applyRoundedEnds(to: button)
    }
    
    static func applyUnselected(to button: UIButton){
        button.backgroundColor = .white
        button.setTitleColor(.coEpiPurple, for:.normal)
        button.layer.borderColor = UIColor.coEpiPurple.cgColor
        button.layer.borderWidth = 1
        applyShadows(to: button)
        applyRoundedEnds(to: button)
    }
    
    static func applyRoundedEnds(to button:  UIButton){
        button.layer.cornerRadius = button.frame.height * 0.50
    }
    
    static func applyShadows(to button: UIButton){
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.25
    }
}
