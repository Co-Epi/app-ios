import Foundation
import UIKit

struct OnboardingStrings {
    
    static let howYourDataIsUsed = "How your data is used"
    static let getStarted = "Get Started"
    static let collaborate = "Collaborate. Inform. Protect."
    
    static func makeAttributedTrack() -> NSMutableAttributedString {
        let newString = NSMutableAttributedString()
        newString.append(makeBold("Track"))
        newString.append(makeLight(" where you've been"))
        return newString
    }
    
    static func makeAttributedMonitor() -> NSMutableAttributedString {
         let newString = NSMutableAttributedString()
         newString.append(makeBold("Monitor"))
         newString.append(makeLight(" your health"))
         return newString
    }
    
    static func makeAttributedAlerts() -> NSMutableAttributedString {
       let newString = NSMutableAttributedString()
        newString.append(makeLight("Get"))
        newString.append(makeBold(" contextualized alerts"))
        newString.append(makeLight(" about possible exposure to infectious illness"))
        return newString
    }
    
    static func makeBold(_ txt: String) -> NSAttributedString {
        NSAttributedString(string: txt, attributes: [NSAttributedString.Key.font: Fonts.robotoBold])
    }
    
    static func makeLight(_ txt: String) -> NSAttributedString {
        NSAttributedString(string: txt, attributes: [NSAttributedString.Key.font: Fonts.robotoLight])
    }
    
    
}
