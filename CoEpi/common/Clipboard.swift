import UIKit

class Clipboard {

    func putInClipboard(text: String) {
        UIPasteboard.general.string = text
    }
}
