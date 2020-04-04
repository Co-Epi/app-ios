
import UIKit

enum FontNames : String {
    case robotoRegular = "Roboto-Regular"
    case robotoLight = "Roboto-Light"
    case robotoBold = "Roboto-Bold"
}

class Fonts {
    static var robotoRegular : UIFont = { guard let font = UIFont(name: FontNames.robotoRegular.rawValue , size: 18)
        else {
            fatalError(fatalFontErrorMessage(font: .robotoRegular))
        }
        return font
    }()
    
    static var robotoLight : UIFont = { guard let font = UIFont(name: FontNames.robotoLight.rawValue , size: 18)
        else {
            fatalError(fatalFontErrorMessage(font: .robotoLight))
        }
        return font
    }()
    
    static var robotoBold : UIFont = { guard let font = UIFont(name: FontNames.robotoBold.rawValue , size: 18)
        else {
            fatalError(fatalFontErrorMessage(font: .robotoBold))
        }
        return font
    }()
    
    static var robotoBold14 : UIFont = { guard let font = UIFont(name: FontNames.robotoBold.rawValue , size: 14)
        else {
            fatalError(fatalFontErrorMessage(font: .robotoBold))
        }
        return font
    }()
    
    static func fatalFontErrorMessage(font: FontNames) -> String {
        let message = """
            Failed to load the "\(font.rawValue)" font.
            Make sure the font file is included in the project and the font name is spelled correctly.
            """
        return message
    }
}
