import Foundation
import UIKit

struct ButtonStyles{
    
    private init(){}
    
    static func applyStyleHomeCard(to button: UIButton){
        button.layer.cornerRadius = 15
        applyStyleShadows(to: button)
    }
    
    static func applyStyleSelectedButton(to button : UIButton){
        button.backgroundColor = .coEpiPurple
        button.setTitleColor(.white, for:.normal)
        applyStyleShadows(to: button)
        applyStyleRoundedEnds(to: button)
    }
    
    static func applyStyleUnselectedButton(to button: UIButton){
        button.backgroundColor = .white
        button.setTitleColor(.coEpiPurple, for:.normal)
        button.layer.borderColor = UIColor.coEpiPurple.cgColor
        button.layer.borderWidth = 1
        applyStyleShadows(to: button)
        applyStyleRoundedEnds(to: button)
    }
    
    static func applyStyleRoundedEnds(to button:  UIButton){
        button.layer.cornerRadius = button.frame.height * 0.50
    }
    
    static func applyStyleShadows(to button: UIButton){
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.25
    }
}
