import Foundation
import UIKit

class Sharer {

    func share(viewController: UIViewController, sourceView: UIView? = nil, completion: (() -> Void)? = nil) {

        if let myWebsite = URL(string: "https://CoEpi.org") { // Enter iOS app link here
            let activityVC = createActivityViewController(
                textToShare: "Help us test CoEpi: together we can protect each other and our loved ones from the spread of contagious illnesses by anonymously letting others know if we develop symptoms",
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
