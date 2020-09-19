import UIKit
import UserNotifications

class NotificationsDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let rootNav: RootNav

    init(rootNav: RootNav) {
        self.rootNav = rootNav
        super.init()

        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void
    ) {
        // Used to display notification while app is in FG
        // TODO: maybe in-app notification/popup?
        completionHandler([
            .badge,
            .alert,
            .sound,
        ])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler _: @escaping ()
            -> Void
    ) {
        let identifierStr = response.notification.request.identifier
        var identifier: NotificationId
        if "alerts" == identifierStr {
            identifier = .alerts
        } else{
            identifier = NotificationId.reminders(identifierStr)
            switch identifier {
            case .alerts: rootNav.navigate(command: .to(destination: .alerts))
            case .reminders: rootNav.navigate(command: .to(destination: .symptomReport))
            }

        }
    }
}
