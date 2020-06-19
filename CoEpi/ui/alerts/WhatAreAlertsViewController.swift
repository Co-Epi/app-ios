import UIKit

class WhatAreAlertsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var bodyLabel: UILabel!

    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Background_white.png")!)

        titleLabel.text = L10n.WhatExposure.title

        bodyLabel.attributedText = L10n.WhatExposure.htmlBody.htmlToAttributedString
    }
}

private extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            log.e("Couldn't encode string: \(self)")
            return NSAttributedString()
        }

        do {
            return try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)

        } catch let e {
            log.e("Couldn't create attributed string with: \(self), e: \(e)")
            return NSAttributedString()
        }
    }
}
