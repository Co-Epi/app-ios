import UIKit
import os.log

protocol NotificationShower {
    func showNotification(data: NotificationData)
}

class NotificationShowerImpl: NotificationShower {

    func showNotification(data: NotificationData) {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.showNotification(data: data, settings: settings)
        }
    }

    private func showNotification(data: NotificationData, settings: UNNotificationSettings) {
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        if settings.alertSetting == .enabled {
            showNotification(data: data, canPlaySound: settings.soundSetting == .enabled)
        }
        // Note: If alert isn't enabled, we don't play sound either
    }

    private func showNotification(data: NotificationData, canPlaySound: Bool) {
        os_log("Showing notification", log: servicesLog, type: .debug)

        let content = UNMutableNotificationContent()
        content.title = data.title
        content.body = data.body
        content.sound = canPlaySound ? .default : nil
        let request = UNNotificationRequest(identifier: data.id.rawValue, content: content,
                                            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                                                       repeats: false))
        UNUserNotificationCenter.current().add(request)
    }
}

struct NotificationData {
    let id: NotificationId
    let title: String
    let body: String
}

enum NotificationId: String {
    case alerts
}
