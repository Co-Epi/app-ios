import Foundation
import UIKit

class Sharer {

    func share(viewController: UIViewController, sourceView: UIView? = nil, completion: (() -> Void)? = nil) {

        if let myWebsite = URL(string: "https://google.com") { // Enter iOS app link here
            let activityVC = createActivityViewController(
                textToShare: "Sharing this app will help slow the spread of Covid-19",
                websiteUrl: myWebsite // Enter iOS app link here
            )

            if let sourceView = sourceView {
                activityVC.popoverPresentationController?.sourceView = sourceView
            }

            viewController.present(activityVC, animated: true, completion: completion)
        }
    }

    private func createActivityViewController(textToShare: String, websiteUrl: URL) -> UIActivityViewController {
        let objectsToShare = [textToShare, websiteUrl] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.airDrop, .addToReadingList, .assignToContact, .openInIBooks,
                                            .saveToCameraRoll]
        return activityVC
    }
}
