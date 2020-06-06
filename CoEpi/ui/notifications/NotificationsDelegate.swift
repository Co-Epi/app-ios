import UIKit
import UserNotifications
import os.log

class NotificationsDelegate: NSObject, UNUserNotificationCenterDelegate {

    private let rootNav: RootNav

    init(rootNav: RootNav) {
        self.rootNav = rootNav
        super.init()

        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        // Used to display notification while app is in FG
        // TODO maybe in-app notification/popup?
        completionHandler([.badge, .alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let identifierStr = response.notification.request.identifier

        guard let identifier = NotificationId(rawValue: identifierStr) else {
            os_log("Selected notification with unknown id: %{public}@", log: servicesLog, type: .debug, identifierStr)
            return
        }

        switch identifier {
        case .alerts: rootNav.navigate(command: .to(destination: .alerts))
        }
    }
}
