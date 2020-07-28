import UIKit

protocol Email {
    func openEmail(address: String, subject: String)
}

class EmailImpl: Email {
    func openEmail(address: String, subject: String) {
        guard let url = URL(string: "mailto:?to=\(address)&subject=\(subject)") else {
            log.e("Couldn't create email URL for: \(address), \(subject)", tags: .ui)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
