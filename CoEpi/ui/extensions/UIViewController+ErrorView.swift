import Foundation
import UIKit
import SwiftEntryKit

protocol ErrorDisplayer {
    func showNotification(notification: UINotification)
}

extension ErrorDisplayer where Self: UIViewController {

    func showNotification(notification: UINotification) {
        let data: (title: String, message: String, color: UIColor) = {
            switch notification {
            case .error(let message): return ("Error", message, .red)
            case .success(let message): return ("Success", message, .systemGreen)
            }
        }()
        SwiftEntryKit.display(entry: createView(title: data.title, message: data.message),
                              using: attributes(backgroundColor: data.color))
    }

    private func createView(title: String, message: String) -> UIView {

        let title = EKProperty.LabelContent(text: title,
                                            style: .init(font: .systemFont(ofSize: 18), color: .white))
        let description = EKProperty.LabelContent(text: message,
                                                  style: .init(font: .systemFont(ofSize: 18), color: .white))
        let simpleMessage = EKSimpleMessage(image: nil, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        return EKNotificationMessageView(with: notificationMessage)
//        return ErrorView(error: message)
    }

    private func attributes(backgroundColor: UIColor) -> EKAttributes {
        var attributes = EKAttributes.topFloat
        attributes.precedence = .enqueue(priority: .normal)
        attributes.windowLevel = .alerts

        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation

        attributes.displayDuration = 4
        attributes.entryBackground = .color(color: EKColor(backgroundColor))
        attributes.positionConstraints.verticalOffset = 0
        return attributes
    }
}
