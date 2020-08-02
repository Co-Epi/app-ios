import UIKit

extension UIColor {
    class var coEpiPurple: UIColor {
        if let color = UIColor(named: "CoEpiPurple") {
            return color
        }
        fatalError("Could not find coEpiPurple")
    }

    class var coEpiPurpleHighlighted: UIColor {
        UIColor(hex: "8702D4")
    }

    class var coEpiLightGray: UIColor {
        if let color = UIColor(named: "CoEpiLightGray") {
            return color
        }
        fatalError("Could not find CoEpiLightGray")
    }
}
