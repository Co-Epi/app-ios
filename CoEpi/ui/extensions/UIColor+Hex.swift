import UIKit

extension UIColor {
        
    func hex(includeAlpha: Bool = true) -> String  {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        guard r >= 0 && r <= 1 && g >= 0 && g <= 1 && b >= 0 && b <= 1 else {
            return "#000"
        }
        
        let alpha = a.isNaN ? 1.0 : a
        
        return includeAlpha
            ? String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(alpha * 255))
            : String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        
    }
    
}
