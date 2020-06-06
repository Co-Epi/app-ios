import UIKit

typealias FontAttributes = [NSAttributedString.Key: Any]

extension String {
    
    static private let htmlOptions: [NSAttributedString.DocumentReadingOptionKey : Any] = [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
    ]
    
    private func css(pointSize: CGFloat, color: UIColor) -> String {
        return """
<style>
    html * {
        font-size: \(pointSize)pt;
        color: \(color.hex());
        font-family: sans-serif;
    }
    .text-center {
        text-align: center;
    }
</style>
"""
    }
    
    private func html(string: String, pointSize: CGFloat, color: UIColor) -> Data? {
        return "\(css(pointSize: pointSize, color: color))\(string)"
            .data(using: .utf8)
    }

    func markupAttributed(pointSize: CGFloat, color: UIColor) -> NSAttributedString {
        
        guard let data = html(string: self, pointSize: pointSize, color: color),
            let attributedString = try? NSAttributedString(data: data,
                                                           options: String.htmlOptions,
                                                           documentAttributes: nil) else {
                return NSAttributedString(string: self)
        }
        
        return attributedString
        
    }

}
