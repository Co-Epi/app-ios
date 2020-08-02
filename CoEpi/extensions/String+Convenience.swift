import Foundation

extension String {
    func toBase64() -> String {
        // https://forums.swift.org/t/can-encoding-string-to-data-with-utf8-fail/22437
        Data(utf8).base64EncodedString()
    }

    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}
