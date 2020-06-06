import Foundation
import UIKit

struct OnboardingStrings {
    
    static let howYourDataIsUsed = L10n.Onboarding.howDataUsed
    static let getStarted = L10n.Onboarding.getStarted
    static let collaborate = L10n.Onboarding.logo
    
    static func makeAttributedTrack() -> NSMutableAttributedString {
        let newString = NSMutableAttributedString()
        newString.append(makeLight(L10n.Onboarding.Track.beforeBold))
        newString.append(makeBold(L10n.Onboarding.Track.bold))
        newString.append(makeLight(L10n.Onboarding.Track.afterBold))
        return newString
    }
    
    static func makeAttributedMonitor() -> NSMutableAttributedString {
         let newString = NSMutableAttributedString()
        newString.append(makeLight(L10n.Onboarding.Monitor.beforeBold))
        newString.append(makeBold(L10n.Onboarding.Monitor.bold))
        newString.append(makeLight(L10n.Onboarding.Monitor.afterBold))
         return newString
    }
    
    static func makeAttributedAlerts() -> NSMutableAttributedString {
       let newString = NSMutableAttributedString()
        newString.append(makeLight(L10n.Onboarding.Alerts.beforeBold))
        newString.append(makeBold(L10n.Onboarding.Alerts.bold))
        newString.append(makeLight(L10n.Onboarding.Alerts.afterBold))
        return newString
    }
    
    static func makeBold(_ txt: String) -> NSAttributedString {
        NSAttributedString(string: txt, attributes: [NSAttributedString.Key.font: Fonts.robotoBold])
    }
    
    static func makeLight(_ txt: String) -> NSAttributedString {
        NSAttributedString(string: txt, attributes: [NSAttributedString.Key.font: Fonts.robotoLight])
    }
    
    
}
