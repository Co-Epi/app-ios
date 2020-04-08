import Foundation

extension String {

    func toBase64() -> String? {
        data(using: String.Encoding.utf8)?.base64EncodedString()
    }
}
